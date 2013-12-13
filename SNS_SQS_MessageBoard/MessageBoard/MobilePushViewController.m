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

#import "MobilePushViewController.h"
#import "Constants.h"
#import "MessageBoard.h"
#import "EndpointsListTableViewController.h"

@interface MobilePushViewController ()

@end

@implementation MobilePushViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [MessageBoard instance];
    
    self.title = @"SNS Mobile Push";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createEndpointButtonPressed:(id)sender {
    
    //To createPlatformEndpoint, we need to obtain PlatformApplicationArn first
    if ( [PLATFORM_APPLICATION_ARN isEqualToString:@"CHANGE ME"]) {
        [[Constants platformApplicationARNAlert] show];
        return;
    }
    
    if ([[MessageBoard instance] createApplicationEndpoint]) {
         [[Constants universalAlertsWithTitle:@"Succeed" andMessage:@"Device Endpoint has been created successfully."] show];
    }

}

- (IBAction)pushButtonPressed:(id)sender {
    
    [self.pushMessageTextField resignFirstResponder];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        [[MessageBoard instance] pushToMobile:self.pushMessageTextField.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
    
}

- (IBAction)viewEndpointsListBtnPressed:(id)sender {
    
    EndpointsListTableViewController *vc = [EndpointsListTableViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];

    
}
- (void)dealloc {
    [_pushMessageTextField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setPushMessageTextField:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField Delegate Method

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:self.pushMessageTextField up:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:self.pushMessageTextField up:NO];
}

-(void)animateTextField:(UITextField *)textField up:(BOOL)moveUp
{
    int move = 100;
    
    if (moveUp) {
        move = -100;
    }
    
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.25f];
    self.view.frame = CGRectOffset(self.view.frame, 0, move);
    [UIView commitAnimations];
}

@end
