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

#import "S3TransferManagerUploadViewController.h"
#import "Constants.h"

@interface S3TransferManagerUploadViewController ()

@property (nonatomic, strong) S3TransferOperation *uploadSmallFileOperation;
@property (nonatomic, strong) S3TransferOperation *uploadBigFileOperation;

@property (nonatomic, strong) NSString *pathForSmallFile;
@property (nonatomic, strong) NSString *pathForBigFile;

@end

@implementation S3TransferManagerUploadViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.tm == nil){
        if(![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"]){
            
            // Initialize the S3 Client.
            AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID
                                                             withSecretKey:SECRET_KEY];
            s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
            
            // Initialize the S3TransferManager
            self.tm = [S3TransferManager new];
            self.tm.s3 = s3;
            self.tm.delegate = self;
            
            // Create the bucket
            S3CreateBucketRequest *createBucketRequest = [[S3CreateBucketRequest alloc] initWithName:[Constants transferManagerBucket] andRegion: [S3Region USWest2]];
            @try {
                S3CreateBucketResponse *createBucketResponse = [s3 createBucket:createBucketRequest];
                if(createBucketResponse.error != nil)
                {
                    NSLog(@"Error: %@", createBucketResponse.error);
                }
            }@catch(AmazonServiceException *exception){
                if(![@"BucketAlreadyOwnedByYou" isEqualToString: exception.errorCode]){
                    NSLog(@"Unable to create bucket: %@", exception.error);
                }
            }
            
            // Set the paths for the small and big files
            self.pathForSmallFile = [self generateTempFile: @"small_test_data.txt": kSmallFileSize];
            self.pathForBigFile = [self generateTempFile: @"big_test_data.txt" : kBigFileSize];
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

#pragma mark - Transfer Manager actions

- (IBAction)uploadSmallFile:(id)sender {
    if(self.uploadSmallFileOperation == nil || (self.uploadSmallFileOperation.isFinished && !self.uploadSmallFileOperation.isPaused)){
        self.uploadSmallFileOperation = [self.tm uploadFile:self.pathForSmallFile bucket: [Constants transferManagerBucket] key: kKeyForSmallFile];
    }
}

- (IBAction)uploadBigFile:(id)sender {
    if(self.uploadBigFileOperation == nil || (self.uploadBigFileOperation.isFinished && !self.uploadBigFileOperation.isPaused)){
        self.uploadBigFileOperation = [self.tm uploadFile:self.pathForBigFile bucket: [Constants transferManagerBucket] key: kKeyForBigFile];
    }
}

- (IBAction)pauseUploads:(id)sender {
    [self.tm pauseAllTransfers];
}

- (IBAction)resumeUploads:(id)sender {
    NSArray *ops = [self.tm resumeAllTransfers:self];
    
    // When you resume, the original handle to the S3TransferOperation
    // is no longer valid.  Obtain the new handles
    for (S3TransferOperation *op in ops) {
        if ([op.putRequest.key isEqualToString:kKeyForBigFile]) {
            self.uploadBigFileOperation = op;
        }else if ([op.putRequest.key isEqualToString:kKeyForSmallFile]) {
            self.uploadSmallFileOperation = op;
        }
    }
}

- (IBAction)cancelSmallUpload:(id)sender {
    [self.uploadSmallFileOperation cancel];
    self.uploadSmallFileOperation = nil;
    self.putObjectTextField.text = @"";
}

- (IBAction)cancelBigUpload:(id)sender {
    [self.uploadBigFileOperation cancel];
    self.uploadBigFileOperation = nil;
    self.multipartObjectTextField.text = @"";
}

- (IBAction)cancelAllTransfers:(id)sender {
    [self.tm cancelAllTransfers];
    self.uploadBigFileOperation = nil;
    self.uploadSmallFileOperation = nil;
    self.multipartObjectTextField.text = @"";
    self.putObjectTextField.text = @"";
}

#pragma mark - AmazonServiceRequestDelegate

-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse called: %@", response);
}

-(void)request:(AmazonServiceRequest *)request didSendData:(long long) bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if([((S3PutObjectRequest *)request).key isEqualToString:kKeyForSmallFile]){
        double percent = ((double)totalBytesWritten/(double)totalBytesExpectedToWrite)*100;
        self.putObjectTextField.text = [NSString stringWithFormat:@"%.2f%%", percent];
    }
    else if([((S3PutObjectRequest *)request).key isEqualToString:kKeyForBigFile]) {
        double percent = ((double)totalBytesWritten/(double)totalBytesExpectedToWrite)*100;
        self.multipartObjectTextField.text = [NSString stringWithFormat:@"%.2f%%", percent];
    }
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if([((S3PutObjectRequest *)request).key isEqualToString:kKeyForSmallFile]){
        self.putObjectTextField.text = @"Done";
    }
    else if([((S3PutObjectRequest *)request).key isEqualToString:kKeyForBigFile]) {
        self.multipartObjectTextField.text = @"Done";
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError called: %@", error);
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"didFailWithServiceException called: %@", exception);
}

#pragma mark - Helpers

-(NSString *)generateTempFile: (NSString *)filename : (long long)approximateFileSize {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    if (![fm fileExistsAtPath:filePath]) {
        NSOutputStream * os= [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        NSString * dataString = @"S3TransferManager_V2 ";
        const uint8_t *bytes = [dataString dataUsingEncoding:NSUTF8StringEncoding].bytes;
        long fileSize = 0;
        [os open];
        while(fileSize < approximateFileSize){
            [os write:bytes maxLength:dataString.length];
            fileSize += dataString.length;
        }
        [os close];
    }
    return filePath;
}

@end
