/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "ViewController.h"
#import "Constants.h"
#import "AmazonClientManager.h"
#import "SESManager.h"


@implementation ViewController

@synthesize nameField = _nameField;
@synthesize rating = _rating;
@synthesize commentsField = _commentsField;
@synthesize submitButton = _submitButton;
@synthesize scrollView = _scrollView;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Feedback";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    self.scrollView.contentSize = self.view.frame.size;
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.nameField     = nil;
    self.rating        = nil;
    self.commentsField = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else {
        self.submitButton.enabled = YES;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [_nameField release];
    [_rating release];
    [_commentsField release];
    [_submitButton release];
    [_scrollView release];

    [super dealloc];
}

#pragma mark - IBActions

-(IBAction)submit:(id)sender
{
    [self.nameField resignFirstResponder];
    [self.commentsField resignFirstResponder];

    if (self.nameField.text == nil || self.nameField.text.length == 0
        || self.commentsField.text == nil || self.commentsField.text.length == 0) {
        
        [[[[UIAlertView alloc] initWithTitle:@"Feedback Not Sent"
                                     message:@"Please fill out entire form."
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] autorelease] show];
        return;
    }

    NSString *commnetsText = self.commentsField.text;
    NSString *nameText = self.nameField.text;
    int rating = self.rating.selectedSegmentIndex + 1;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        BOOL didSucceed = [SESManager sendFeedbackEmail:commnetsText
                                                   name:nameText
                                                 rating:rating];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if (didSucceed) {

                [[[[UIAlertView alloc] initWithTitle:@"Feedback Sent"
                                             message:@"Thank you for your feedback!"
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] autorelease] show];
            }
            else {
                [[[[UIAlertView alloc] initWithTitle:@"Feedback Failed"
                                             message:@"Unable to send feedback at this time."
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] autorelease] show];
            }
        });
    });
}

#pragma mark - Helper Methods

- (void)keyboardDidShown:(NSNotification *)notification
{
    CGSize kbSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, kbSize.height, self.scrollView.contentInset.right);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, 0.0, self.scrollView.contentInset.right);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark

@end