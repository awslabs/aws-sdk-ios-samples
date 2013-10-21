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


#import "Message_BoardViewController.h"
#import "MessageBoard.h"
#import "MembersViewController.h"
#import "MessageQueueController.h"
#import "Constants.h"

// Main View
@implementation Message_BoardViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]) {
        [[Constants credentialsAlert] show];
    }
    
    self.title = @"Message Board";
}

-(IBAction)subscribeEmail:(id)sender
{
    [email resignFirstResponder];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        [[MessageBoard instance] subscribeEmail:email.text];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [[Constants confirmationAlert] show];
        });
    });
}

-(IBAction)subscribeSMS:(id)sender
{
    [sms resignFirstResponder];

    if ( [sms.text length] < 10) {
        [[Constants smsSubscriptionAlert] show];
    }
    else {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            [[MessageBoard instance] subscribeSms:sms.text];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [[Constants confirmationAlert] show];
            });
        });        
    }
}

-(IBAction)viewMembers:(id)sender
{
    MembersViewController *members = [MembersViewController new];
    [self.navigationController pushViewController:members animated:YES];
    [members release];
}

-(IBAction)viewQueue:(id)sender
{
    if (!seenQueueMessage) {
        seenQueueMessage = YES;
        [[Constants queueAlert] show];
    }
    else {
        MessageQueueController *queue = [MessageQueueController new];
        [self.navigationController pushViewController:queue animated:YES];
        [queue release];
    }
}

-(IBAction)post:(id)sender
{
    [message resignFirstResponder];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        [[MessageBoard instance] post:message.text];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:sms up:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:sms up:NO];
}

-(void)animateTextField:(UITextField *)textField up:(BOOL)moveUp
{
    int move = 20;

    if (moveUp) {
        move = -20;
    }

    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25f];
    self.view.frame = CGRectOffset(self.view.frame, 0, move);
    [UIView commitAnimations];
}

-(void)dealloc
{
    [super dealloc];
}

@end
