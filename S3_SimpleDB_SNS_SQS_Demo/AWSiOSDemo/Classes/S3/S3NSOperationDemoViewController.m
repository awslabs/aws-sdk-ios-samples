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

#import "S3NSOperationDemoViewController.h"
#import "AsyncImageUploader.h"
#import "AsyncImageDownloader.h"
#import "AmazonClientManager.h"

@implementation S3NSOperationDemoViewController

#pragma mark - View lifecycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = @"S3 NSOperation Demo";
        
        operationQueue = [NSOperationQueue new];
        operationQueue.maxConcurrentOperationCount = 3;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        [self deleteBucket];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - User Action Methods

-(IBAction)uploadImages:(id)sender
{
    AsyncImageUploader *imageUploader1 = [[AsyncImageUploader alloc] initWithImageNo:1 progressView:uploadProgress1];
    
    [operationQueue addOperation:imageUploader1];
    [imageUploader1 release];
    
    AsyncImageUploader *imageUploader2 = [[AsyncImageUploader alloc] initWithImageNo:2 progressView:uploadProgress2];
    [operationQueue addOperation:imageUploader2];
    [imageUploader2 release];
    
    AsyncImageUploader *imageUploader3 = [[AsyncImageUploader alloc] initWithImageNo:3 progressView:uploadProgress3];
    [operationQueue addOperation:imageUploader3];
    [imageUploader3 release];
}

-(IBAction)downloadImages:(id)sender
{
    AsyncImageDownloader *imageDownloader1 = [[AsyncImageDownloader alloc] initWithImageNo:1 progressView:downloadProgress1 imageview:downloadImage1];
    
    [operationQueue addOperation:imageDownloader1];
    [imageDownloader1 release];
    
    AsyncImageDownloader *imageDownloader2 = [[AsyncImageDownloader alloc] initWithImageNo:2 progressView:downloadProgress2 imageview:downloadImage2];
    [operationQueue addOperation:imageDownloader2];
    [imageDownloader2 release];
    
    AsyncImageDownloader *imageDownloader3 = [[AsyncImageDownloader alloc] initWithImageNo:3 progressView:downloadProgress3 imageview:downloadImage3];
    [operationQueue addOperation:imageDownloader3];
    [imageDownloader3 release];
}

#pragma mark - Helper Methods

-(void)deleteBucket
{
    // Gets all of the objects in the test bucket.
    NSString              *bucketName   = [NSString stringWithFormat:@"s3-async-demo2-ios-for-%@", [ACCESS_KEY_ID lowercaseString]];
    S3ListObjectsRequest  *listRequest  = [[[S3ListObjectsRequest alloc] initWithName:bucketName] autorelease];
    S3ListObjectsResponse *listResponse = [[AmazonClientManager s3] listObjects:listRequest];
    if(listResponse.error != nil)
    {
        NSLog(@"Error: %@", listResponse.error);
    }
    
    // Deletes each object in the test bucket.
    S3DeleteObjectRequest *deleteRequest = nil;
    for (S3ObjectSummary *os in listResponse.listObjectsResult.objectSummaries)
    {
        deleteRequest        = [S3DeleteObjectRequest new];
        deleteRequest.bucket = bucketName;
        deleteRequest.key    = os.key;
        
        S3DeleteObjectResponse *deleteObjectResponse = [[AmazonClientManager s3] deleteObject:deleteRequest];
        if(deleteObjectResponse.error != nil)
        {
            NSLog(@"Error: %@", deleteObjectResponse.error);
        }
        
        [deleteRequest release];
    }
    
    // Deletes the test bucket. The bucket must be empty in order to be deleted.
    S3DeleteBucketRequest *deleteBucketReqeust = [[S3DeleteBucketRequest alloc] initWithName:bucketName];
    S3DeleteBucketResponse *deleteBucketResponse = [[AmazonClientManager s3] deleteBucket:deleteBucketReqeust];
    if(deleteBucketResponse.error != nil)
    {
        NSLog(@"Error: %@", deleteBucketResponse.error);
    }
    
    [deleteBucketReqeust release];
}

#pragma mark -

@end