/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "CognitoHomeViewController.h"
#import "AmazonClientManager.h"
#import "BFTask.h"

@implementation CognitoHomeViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self disableUI];
	
    [[AmazonClientManager sharedInstance] resumeSessionWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    }];
}

-(IBAction)loginClicked:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self disableUI];
    [[AmazonClientManager sharedInstance] loginFromView:self.view withCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    }];
}

-(IBAction)logoutClicked:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self disableUI];
    [[AmazonClientManager sharedInstance] logoutWithCompletionHandler:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshUI];
        });
    }];
}

-(void)disableUI {
    self.browseDataButton.enabled = NO;
    self.loginButton.enabled = NO;
    self.logoutWipeButton.enabled = NO;
}

-(void)refreshUI {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.browseDataButton.enabled = YES;
    self.loginButton.enabled = YES;
    if ([[AmazonClientManager sharedInstance] isLoggedIn]) {
        self.loginButton.titleLabel.text = @"Link";
    }
    else {
        self.loginButton.titleLabel.text = @"Login";
    }
    self.logoutWipeButton.enabled = [[AmazonClientManager sharedInstance] isLoggedIn];
}

@end
