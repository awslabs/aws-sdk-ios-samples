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

#import "SecondViewController.h"
#import "S3.h"
#import "Constants.h"
#import "DisplayImageController.h"


@interface SecondViewController ()

@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest1;
@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest2;
@property (nonatomic, strong) AWSS3TransferManagerDownloadRequest *downloadRequest3;

@property (strong, nonatomic) IBOutlet UIProgressView *progressView1;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView2;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView3;

@property (nonatomic) int64_t file1Size;
@property (nonatomic) int64_t file1AlreadyDownloaded;

@property (nonatomic) int64_t file2Size;
@property (nonatomic) int64_t file2AlreadyDownloaded;

@property (nonatomic) int64_t file3Size;
@property (nonatomic) int64_t file3AlreadyDownloaded;

@property (nonatomic) int fileIndex;

@end



@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    [self cleanProgress];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downloadButtonPressed:(id)sender {
    
    NSString *downloadingFilePath1 = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName1];
    NSURL *downloadingFileURL1 = [NSURL fileURLWithPath:downloadingFilePath1];

    NSString *downloadingFilePath2 = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName2];
    NSURL *downloadingFileURL2 = [NSURL fileURLWithPath:downloadingFilePath2];
    
    NSString *downloadingFilePath3 = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName3];
    NSURL *downloadingFileURL3 = [NSURL fileURLWithPath:downloadingFilePath3];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:downloadingFilePath1]) {
        if (![fileManager removeItemAtPath:downloadingFilePath1
                                     error:&error]) {
            NSLog(@"Error: %@", error);
        }
    }

    if ([fileManager fileExistsAtPath:downloadingFilePath2]) {
        if (![fileManager removeItemAtPath:downloadingFilePath2
                                     error:&error]) {
            NSLog(@"Error: %@", error);
        }
    }
    
    if ([fileManager fileExistsAtPath:downloadingFilePath3]) {
        if (![fileManager removeItemAtPath:downloadingFilePath3
                                     error:&error]) {
            NSLog(@"Error: %@", error);
        }
    }
    
    //download files
    self.downloadStatusLabel.text = StatusLabelDownloading;
    [self cleanProgress];
    __weak typeof(self) weakSelf = self;
    
    self.downloadRequest1 = [AWSS3TransferManagerDownloadRequest new];
    self.downloadRequest1.bucket = S3BucketName;
    self.downloadRequest1.key = S3KeyDownloadName1;
    self.downloadRequest1.downloadingFileURL = downloadingFileURL1;
    self.downloadRequest1.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        // update progress
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1AlreadyDownloaded = totalBytesWritten;
            weakSelf.file1Size = totalBytesExpectedToWrite;
            [weakSelf updateProgress];
        });

    };

    
    self.downloadRequest2 = [AWSS3TransferManagerDownloadRequest new];
    self.downloadRequest2.bucket = S3BucketName;
    self.downloadRequest2.key = S3KeyDownloadName2;
    self.downloadRequest2.downloadingFileURL = downloadingFileURL2;
    self.downloadRequest2.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        // update progress
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file2AlreadyDownloaded = totalBytesWritten;
            weakSelf.file2Size = totalBytesExpectedToWrite;
            [weakSelf updateProgress];
        });
        
    };
    
    self.downloadRequest3 = [AWSS3TransferManagerDownloadRequest new];
    self.downloadRequest3.bucket = S3BucketName;
    self.downloadRequest3.key = S3KeyDownloadName3;
    self.downloadRequest3.downloadingFileURL = downloadingFileURL3;
    self.downloadRequest3.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite){
        // update progress
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file3AlreadyDownloaded = totalBytesWritten;
            weakSelf.file3Size = totalBytesExpectedToWrite;
            [weakSelf updateProgress];
        });
        
    };

    
    
    [self downloadFiles];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    __block int cancelCount = 0;
    [[self.downloadRequest1 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        self.downloadRequest1 = nil;
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            cancelCount++;
            if(3 == cancelCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.downloadRequest2 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        self.downloadRequest2 = nil;
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            cancelCount++;
            if(3 == cancelCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.downloadRequest3 cancel] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        self.downloadRequest3 = nil;
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            cancelCount++;
            if(3 == cancelCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
}

- (IBAction)pauseButtonPressed:(id)sender {
    
    __block int pauseCount = 0;
    [[self.downloadRequest1 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.downloadRequest2 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
    
    [[self.downloadRequest3 pause] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if(task.error!=nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused) {
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            pauseCount++;
            if(3 == pauseCount)
                self.downloadStatusLabel.text = StatusLabelReady;
        }
        return nil;
    }];
}

- (IBAction)resumeButtonPressed:(id)sender {
    [self downloadFiles];
}


- (void)updateProgress {
    
    if (self.file1AlreadyDownloaded <= self.file1Size)
    {
        self.progressView1.progress = (float)self.file1AlreadyDownloaded / (float)self.file1Size;
    }
    
    if (self.file2AlreadyDownloaded <= self.file2Size)
    {
        self.progressView2.progress = (float)self.file2AlreadyDownloaded / (float)self.file2Size;
    }
    
    if (self.file3AlreadyDownloaded <= self.file3Size)
    {
        self.progressView3.progress = (float)self.file3AlreadyDownloaded / (float)self.file3Size;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *viewButton = (UIButton*)sender;
    DisplayImageController * viewController = segue.destinationViewController;
    viewController.fileIndex =(int) viewButton.tag;
}


- (void) cleanProgress {
    self.progressView1.progress = 0;
    self.progressView2.progress = 0;
    self.progressView3.progress = 0;
    
    self.file1Size = 0;
    self.file1AlreadyDownloaded = 0;

    self.file2Size = 0;
    self.file2AlreadyDownloaded = 0;
    
    self.file3Size = 0;
    self.file3AlreadyDownloaded = 0;
}

- (void) downloadFiles {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    self.downloadStatusLabel.text = StatusLabelDownloading;

    __block int downloadCount = 0;
    [[transferManager download:self.downloadRequest1] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.downloadRequest1 = nil;
            downloadCount++;
            if(3 == downloadCount){
                self.downloadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];
    
    
    [[transferManager download:self.downloadRequest2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.downloadRequest2 = nil;
            downloadCount++;
            if(3 == downloadCount){
                self.downloadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];
    
    [[transferManager download:self.downloadRequest3] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                self.downloadStatusLabel.text = StatusLabelFailed;
            }
        } else {
            self.downloadRequest3 = nil;
            downloadCount++;
            if(3 == downloadCount){
                self.downloadStatusLabel.text = StatusLabelCompleted;
            }
        }
        return nil;
    }];
    
    
}

@end
