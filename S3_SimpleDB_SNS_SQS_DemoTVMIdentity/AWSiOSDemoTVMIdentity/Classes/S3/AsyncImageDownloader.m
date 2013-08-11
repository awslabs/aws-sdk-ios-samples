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

#import "AsyncImageDownloader.h"
#import "AmazonClientManager.h"

@implementation AsyncImageDownloader

#pragma mark - Class Lifecycle

-(id)initWithImageNo:(int)theImageNo progressView:(UIProgressView *)theProgressView imageview:(UIImageView *)theImageView
{
    self = [super init];
    if (self)
    {
        imageNo      = theImageNo;
        progressView = [theProgressView retain];
        imageView    = [theImageView retain];

        isExecuting = NO;
        isFinished  = NO;
    }

    return self;
}

-(void)dealloc
{
    [progressView release];
    [imageView release];

    [super dealloc];
}

#pragma mark - Overwriding NSOperation Methods

/*
 * For concurrent operations, you need to override the following methods:
 * start, isConcurrent, isExecuting and isFinished.
 *
 * Please refer to the NSOperation documentation for more details.
 * http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/NSOperation_class/Reference/Reference.html
 */

-(void)start
{
    // Makes sure that start method always runs on the main thread.
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    [self performSelectorOnMainThread:@selector(initialize) withObject:nil waitUntilDone:NO];

    NSString *bucketName = [NSString stringWithFormat:@"s3-async-demo2-ios-for-%@", [ACCESS_KEY_ID lowercaseString]];
    NSString *keyName    = [NSString stringWithFormat:@"image%d", imageNo];

    // Puts the file as an object in the bucket.
    S3GetObjectRequest *getObjectRequest = [[[S3GetObjectRequest alloc] initWithKey:keyName withBucket:bucketName] autorelease];
    getObjectRequest.delegate = self;

    [[AmazonClientManager s3] getObject:getObjectRequest];
}

-(BOOL)isConcurrent
{
    return YES;
}

-(BOOL)isExecuting
{
    return isExecuting;
}

-(BOOL)isFinished
{
    return isFinished;
}

#pragma mark - AmazonServiceRequestDelegate Implementations

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    [self performSelectorOnMainThread:@selector(hideProgressView) withObject:nil waitUntilDone:NO];

    UIImage *image = [UIImage imageWithData:response.body];
    [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];

    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    // The progress bar for downlaod is just an estimate. In order to accurately reflect the progress bar, you need to first retrieve the file size.
    [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:[NSNumber numberWithFloat:(float)[data length] / 150 / 1024] waitUntilDone:NO];
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);

    [self finish];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"%@", exception);

    [self finish];
}

#pragma mark - Helper Methods

-(void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    isExecuting = NO;
    isFinished  = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

-(void)initialize
{
    progressView.hidden   = NO;
    progressView.progress = 0.0;

    imageView.image = nil;
}

-(void)updateProgressView:(NSNumber *)theProgress
{
    progressView.progress = [theProgress floatValue];
}

-(void)hideProgressView
{
    progressView.hidden = YES;
}

-(void)setImage:(UIImage *)theImage
{
    imageView.image = theImage;
}

#pragma mark -

@end
