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

#import "S3TransferManagerDownloadViewController.h"
#import "Constants.h"

@interface S3TransferManagerDownloadViewController ()

@property (nonatomic, strong) S3TransferOperation *downloadFileOperation;
@property (nonatomic) double totalBytesWritten;
@property (nonatomic) long long expectedTotalBytes;
@property (nonatomic) NSString * filePath;

@end

@implementation S3TransferManagerDownloadViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	
    if(self.tm == nil){
        if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]
           )
        {
            // Initialize the S3 Client.
            AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID
                                                             withSecretKey:SECRET_KEY];
            s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
            
            // Initialize the TransferManager
            self.tm = [S3TransferManager new];
            self.tm.s3 = s3;
            self.tm.delegate = self;
            
        }else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:CREDENTIALS_ERROR_TITLE
                                                              message:CREDENTIALS_ERROR_MESSAGE
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
        }
    }
}

#pragma mark - Transfer Manager Actions

- (IBAction)downloadFile:(id)sender {
    if(self.downloadFileOperation == nil || (self.downloadFileOperation.isFinished && !self.downloadFileOperation.isPaused)){
        self.filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"download-tm-small-file.txt"];
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error: nil];
        self.totalBytesWritten = 0;
        self.downloadFileOperation = [self.tm downloadFile:self.filePath bucket:[Constants transferManagerBucket] key:kKeyForSmallFile];
    }
}

- (IBAction)pauseDownload:(id)sender {
    [self.tm pauseAllTransfers];
}

- (IBAction)resumeDownload:(id)sender {
    // When you resume, the original handle to the S3TransferOperation
    // is no longer valid.  Update with the new handle.
    self.downloadFileOperation = [self.tm resume:self.downloadFileOperation requestDelegate:self];
}

- (IBAction)cancelDownload:(id)sender {
    [self.downloadFileOperation cancel];
    self.getObjectTextField.text = @"";
}

#pragma mark - AmazonServiceRequestDelegate

-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSDictionary * headers = ((NSHTTPURLResponse *)response).allHeaderFields;
    //if content-range is not set (this is not a range download), content-length is the length of the file
    if ([headers objectForKey:(@"Content-Range")] == nil) {
        self.expectedTotalBytes = [[headers objectForKey:(@"Content-Length")] longLongValue];
    }
}

- (void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    self.totalBytesWritten += data.length;
    double percent = ((double)self.totalBytesWritten/(double)self.expectedTotalBytes)*100;
    self.getObjectTextField.text = [NSString stringWithFormat:@"%.2f%%", percent];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    self.getObjectTextField.text = @"Done";
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError called: %@", error);
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"didFailWithServiceException called: %@", exception);
}

@end
