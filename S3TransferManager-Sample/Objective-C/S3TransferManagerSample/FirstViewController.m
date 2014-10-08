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

#import "FirstViewController.h"
#import "S3.h"
#import "Constants.h"

@interface FirstViewController ()

@property (nonatomic, strong) NSURL *testFileURL1;
@property (nonatomic, strong) NSURL *testFileURL2;
@property (nonatomic, strong) NSURL *testFileURL3;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest1;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest2;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest3;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView1;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView2;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView3;


@property (nonatomic) uint64_t file1Size;
@property (nonatomic) uint64_t file2Size;
@property (nonatomic) uint64_t file3Size;

@property (nonatomic) uint64_t file1AlreadyUpload;
@property (nonatomic) uint64_t file2AlreadyUpload;
@property (nonatomic) uint64_t file3AlreadyUpload;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self cleanProgress];
    
    
    BFTask *task = [BFTask taskWithResult:nil];
    [[task continueWithBlock:^id(BFTask *task) {
        // Creates a test file in the temporary directory
        self.testFileURL1 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:S3KeyUploadName1]];

        NSMutableString *dataString = [NSMutableString new];
        for (int32_t i = 1; i < 2000000; i++) {
            [dataString appendFormat:@"%d\n", i];
        }

        NSError *error = nil;
        [dataString writeToURL:self.testFileURL1
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];

        
        self.testFileURL2 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:S3KeyUploadName2]];
        [dataString writeToURL:self.testFileURL2
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];
        
        
        self.testFileURL3 = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:S3KeyUploadName3]];
        [dataString writeToURL:self.testFileURL3
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];
        
        self.file1Size = self.file2Size = self.file3Size = [dataString length];
        
        return nil;
    }] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        self.uploadButton.enabled = YES;
        self.pauseButton.enabled = YES;
        self.resumeButton.enabled = YES;
        self.cancelButton.enabled = YES;

        return nil;
    }];
}

- (IBAction)uploadButtonPressed:(id)sender {

    self.uploadStatusLabel.text = StatusLabelUploading;
    [self cleanProgress];
    
    __weak typeof(self) weakSelf = self;
    
    self.uploadRequest1 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest1.bucket = S3BucketName;
    self.uploadRequest1.key = S3KeyUploadName1;
    self.uploadRequest1.body = self.testFileURL1;
    self.uploadRequest1.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1AlreadyUpload = totalBytesSent;
            [weakSelf updateProgress];
        });
    };
    
    self.uploadRequest2 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest2.bucket = S3BucketName;
    self.uploadRequest2.key = S3KeyUploadName2;
    self.uploadRequest2.body = self.testFileURL2;
    self.uploadRequest2.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file2AlreadyUpload = totalBytesSent;
            [weakSelf updateProgress];
        });
    };
    
    self.uploadRequest3 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest3.bucket = S3BucketName;
    self.uploadRequest3.key = S3KeyUploadName3;
    self.uploadRequest3.body = self.testFileURL3;
    self.uploadRequest3.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file3AlreadyUpload = totalBytesSent;
            [weakSelf updateProgress];
        });
    };
    
    [self uploadFiles];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    __block int cancelCount = 0;
    
    [[self.uploadRequest1 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled)
            {
                NSLog(@"%s Error: [%@]", __PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest1 = nil;
            cancelCount++;
            if(3 == cancelCount)
                self.uploadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.uploadRequest2 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled)
            {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest1 = nil;
            cancelCount++;
            if(3 == cancelCount)
                self.uploadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.uploadRequest3 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if( task.error.code != AWSS3TransferManagerErrorCancelled)
            {
                NSLog(@"%s Error: [%@]", __PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest1 = nil;
            cancelCount++;
            if(3 == cancelCount)
                self.uploadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
}

- (IBAction)pauseButtonPressed:(id)sender {

    __block int pauseCount = 0;
    [[self.uploadRequest1 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if( ! task.error.code == AWSS3TransferManagerErrorCancelled && ! task.error.code == AWSS3TransferManagerErrorPaused )
            {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount) {
                self.uploadStatusLabel.text = StatusLabelReady;
            }
            
        }
        return nil;
    }];
    
    [[self.uploadRequest2 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if( ! task.error.code == AWSS3TransferManagerErrorCancelled && ! task.error.code == AWSS3TransferManagerErrorPaused )
            {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount) {
                self.uploadStatusLabel.text = StatusLabelReady;
            }
        }
        return nil;
    }];
    
    [[self.uploadRequest3 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error != nil){
            if( ! task.error.code == AWSS3TransferManagerErrorCancelled && ! task.error.code == AWSS3TransferManagerErrorPaused )
            {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount) {
                self.uploadStatusLabel.text = StatusLabelReady;
            }
        }
        return nil;
    }];
}

- (IBAction)resumeButtonPressed:(id)sender {
    [self uploadFiles];
}

- (void) uploadFiles {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];

    __block int uploadCount = 0;
    [[transferManager upload:self.uploadRequest1] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
                task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest1 = nil;
            uploadCount ++;
            if(3 == uploadCount){
                self.uploadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];
    
    [[transferManager upload:self.uploadRequest2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
                task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest2 = nil;
            uploadCount ++;
            if(3 == uploadCount){
                self.uploadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];
    
    [[transferManager upload:self.uploadRequest3] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
                task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.uploadRequest3 = nil;
            uploadCount ++;
            if(3 == uploadCount){
                self.uploadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];


}

- (void)updateProgress {
    
    if (self.file1AlreadyUpload <= self.file1Size)
    {
        self.progressView1.progress = (float)self.file1AlreadyUpload / (float)self.file1Size;
    }
    
    if (self.file2AlreadyUpload <= self.file2Size)
    {
        self.progressView2.progress = (float)self.file2AlreadyUpload / (float)self.file2Size;
    }
    
    if (self.file3AlreadyUpload <= self.file3Size)
    {
        self.progressView3.progress = (float)self.file3AlreadyUpload / (float)self.file3Size;
    }
    
}


- (void) cleanProgress {
    self.progressView1.progress = 0;
    self.progressView2.progress = 0;
    self.progressView3.progress = 0;
    
    self.file1AlreadyUpload = 0;
    self.file2AlreadyUpload = 0;
    self.file3AlreadyUpload = 0;
}


@end
