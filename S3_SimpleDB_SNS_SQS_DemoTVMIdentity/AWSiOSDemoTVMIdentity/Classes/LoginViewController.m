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

#import "LoginViewController.h"
#import "AmazonClientManager.h"
#import "Constants.h"
#import "Response.h"

@implementation LoginViewController


-(IBAction)login:(id)sender
{
    Response *response = [AmazonClientManager login:[username text] password:[password text]];

    if (![response wasSuccessful]) {
        [[Constants errorAlert:response.message] show];
    }

    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)reg:(id)sender
{
    NSString *urlString = [NSString stringWithFormat:(USE_SSL ? @"https://%@/%@":@"http://%@/%@"), TOKEN_VENDING_MACHINE_URL, @"register.jsp"];
    NSURL    *url       = [NSURL URLWithString:urlString];

    [[UIApplication sharedApplication] openURL:url];
}

-(void)dealloc
{
    [super dealloc];
}

@end
