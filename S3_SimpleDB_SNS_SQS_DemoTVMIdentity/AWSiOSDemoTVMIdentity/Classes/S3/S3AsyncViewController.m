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


#import "S3AsyncViewController.h"
#import "Constants.h"

@implementation S3AsyncViewController

@synthesize bytesIn, bytesOut;

-(id)init
{
    self = [super initWithNibName:@"S3AsyncViewController" bundle:nil];
    if(self)
    {
        self.title = @"S3 Async";

        // Create the S3 Request Delegate
        s3ResponseHandler = [[S3ResponseHandler alloc] init];
        putObjectRequest  = nil;
        getObjectRequest  = nil;
    }

    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    s3ResponseHandler.bytesIn  = bytesIn;
    s3ResponseHandler.bytesOut = bytesOut;
}

-(IBAction)start:(id)sender
{
    bytesIn.text  = @"0";
    bytesOut.text = @"0";
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(putObject) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getObject) userInfo:nil repeats:NO];
}

-(IBAction)stop:(id)sender
{
    if (putObjectRequest != nil) {
        [putObjectRequest.urlConnection cancel];
    }
    
    if (getObjectRequest != nil) {
        [getObjectRequest.urlConnection cancel];
    }
}

-(void)putObject
{
    NSString *bucketName = [NSString stringWithFormat:@"testing-async-with-s3-for%@", [ACCESS_KEY_ID lowercaseString]];
    NSString *keyName    = @"asyncTestFile";
    NSString *filename   = [[NSBundle mainBundle] pathForResource:@"temp" ofType:@"txt"];
    
    // Create the Bucket to put the Object.
    S3CreateBucketRequest  *createBucketRequest = [[[S3CreateBucketRequest alloc] initWithName:bucketName andRegion:[S3Region USWest2]]autorelease];
    S3CreateBucketResponse *createBucketResponse = [[AmazonClientManager s3] createBucket:createBucketRequest];
    if(createBucketResponse.error != nil)
    {
        NSLog(@"Error: %@", createBucketResponse.error);
    }
    
    // Put the file as an object in the bucket.
    putObjectRequest = [[S3PutObjectRequest alloc] initWithKey:keyName inBucket:bucketName];
    putObjectRequest.filename = filename;
    [putObjectRequest setDelegate:s3ResponseHandler];
    
    // When using delegates the return is nil.
    S3PutObjectResponse *putObjectResponse = [[AmazonClientManager s3] putObject:putObjectRequest];
    if(putObjectResponse.error != nil)
    {
        NSLog(@"Error: %@", putObjectResponse.error);
    }
}

-(void)getObject
{
    NSString *bucketName = [NSString stringWithFormat:@"testing-async-with-s3-for%@", [ACCESS_KEY_ID lowercaseString]];
    NSString *keyName    = @"asyncTestFile";
    
    // Get the object from the bucket.
    getObjectRequest = [[S3GetObjectRequest alloc] initWithKey:keyName withBucket:bucketName];
    [getObjectRequest setDelegate:s3ResponseHandler];
    
    // When using delegates the return is nil.
    [[AmazonClientManager s3] getObject:getObjectRequest];
}

-(void)dealloc
{
    [s3ResponseHandler dealloc];
    [putObjectRequest release];
    [getObjectRequest release];
    [super dealloc];
}

@end