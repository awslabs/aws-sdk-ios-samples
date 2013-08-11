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

#import "ObjectViewController.h"
#import "AmazonClientManager.h"

@implementation ObjectViewController

@synthesize objectNameLabel, objectDataLabel, objectName, bucket;

-(IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        S3GetObjectRequest  *getObjectRequest  = [[[S3GetObjectRequest alloc] initWithKey:self.objectName withBucket:self.bucket] autorelease];
        S3GetObjectResponse *getObjectResponse = [[AmazonClientManager s3] getObject:getObjectRequest];
        if(getObjectResponse.error != nil)
        {
            NSLog(@"Error: %@", getObjectResponse.error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            self.objectNameLabel.text = self.objectName;
            self.objectDataLabel.text = [[[NSString alloc] initWithData:getObjectResponse.body encoding:NSUTF8StringEncoding] autorelease];
        });
    });
    
}

-(void)dealloc
{
    [super dealloc];
}

@end