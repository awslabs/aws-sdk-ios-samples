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

#import "AWSiOSDemoTVMIdentityViewController.h"
#import "Constants.h"
#import "BucketList.h"
#import "DomainList.h"
#import "QueueList.h"
#import "TopicList.h"
#import "S3AsyncViewController.h"
#import "SdbAsyncViewController.h"
#import "AmazonClientManager.h"
#import "LoginViewController.h"
#import "AmazonKeyChainWrapper.h"
#import "S3NSOperationDemoViewController.h"

@implementation AWSiOSDemoTVMIdentityViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"AnonymousTVM";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Top"
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:nil
                                                                  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
}

-(IBAction)listBuckets:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            BucketList *bucketList = [[BucketList alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:bucketList animated:YES];
            [bucketList release];
        }
    }
}

-(IBAction)s3AsyncDemo:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            S3AsyncViewController *s3Async = [S3AsyncViewController new];
            [self.navigationController pushViewController:s3Async animated:YES];
            [s3Async release];
        }
    }
}

-(IBAction)s3NSOperationDemo:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            S3NSOperationDemoViewController *s3Async2 = [[S3NSOperationDemoViewController alloc] initWithNibName:@"S3NSOperationDemoView"
                                                                                                          bundle:nil];
            [self.navigationController pushViewController:s3Async2 animated:YES];
            [s3Async2 release];
        }
    }
}

-(IBAction)listDomains:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            DomainList *domainList = [[DomainList alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:domainList animated:YES];
            [domainList release];
        }
    }
}

-(IBAction)sdbAsyncDemo:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            SdbAsyncViewController *sdbAsync = [SdbAsyncViewController new];
            [self.navigationController pushViewController:sdbAsync animated:YES];
            [sdbAsync release];
        }
    }
}

-(IBAction)listQueues:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            QueueList *queueList = [QueueList new];
            [self.navigationController pushViewController:queueList animated:YES];
            [queueList release];
        }
    }
}

-(IBAction)listTopics:(id)sender
{
    if (![AmazonClientManager hasCredentials]) {
        [[Constants credentialsAlert] show];
    }
    else if (![AmazonClientManager isLoggedIn]) {
        [self login];
    }
    else {
        Response *response = [AmazonClientManager validateCredentials];
        if (![response wasSuccessful]) {
            [[Constants errorAlert:response.message] show];
        }
        else {
            TopicList *topicList = [[TopicList alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:topicList animated:YES];
            [topicList release];
        }
    }
}

-(IBAction)logout:(id)sender
{
    [AmazonClientManager wipeAllCredentials];
    [AmazonKeyChainWrapper wipeKeyChain];
}

-(void)login
{
    LoginViewController *login = [LoginViewController new];
    [self presentModalViewController:login animated:YES];
    [login release];
}

@end
