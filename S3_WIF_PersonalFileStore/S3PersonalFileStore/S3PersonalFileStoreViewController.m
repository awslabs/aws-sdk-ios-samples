/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "S3PersonalFileStoreViewController.h"
#import "Constants.h"
#import "ObjectListing.h"
#import "AmazonClientManager.h"
#import "LoginViewController.h"
#import "AmazonKeyChainWrapper.h"

@implementation S3PersonalFileStoreViewController

-(IBAction)listObjects:(id)sender
{    
    if (![[AmazonClientManager sharedInstance] hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![[AmazonClientManager sharedInstance] isLoggedIn]) {
        [self login];
        //[AIMobileLib authorizeUserForScopes:[NSArray arrayWithObject:@"profile"] delegate:[AmazonClientManager sharedInstance]];
    }
    else {             
        ObjectListing *objectList = [[ObjectListing alloc] init];
        objectList.bucket = BUCKET_NAME;
        objectList.prefix = [AmazonKeyChainWrapper username];
        
        objectList.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        [self presentModalViewController:objectList animated:YES];
        [objectList release];
    }
}

-(IBAction)logout:(id)sender
{
    [[AmazonClientManager sharedInstance] wipeAllCredentials];
    [AmazonKeyChainWrapper wipeKeyChain];
}

-(void)login
{
    LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
    [self presentModalViewController:login animated:YES];
}

-(void)dealloc
{
    [super dealloc];
}

@end
