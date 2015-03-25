/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
#import "AppDelegate.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"

@interface SecondViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:BackgroundSessionDownloadIdentifier];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    self.session = session;
    
    self.progressView.progress = 0;
    self.statusLabel.text = @"Ready";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)start:(id)sender {
    
    if (self.downloadTask)
    {
        return;
    }

    self.imageView.image = nil;
    
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = S3BucketName;
    getPreSignedURLRequest.key = S3DownloadKeyName;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodGET;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(BFTask *task) {
        
        if (task.error) {
            NSLog(@"Error: %@",task.error);
        } else {
            
            NSURL *presignedURL = task.result;
            NSLog(@"download presignedURL is: \n%@", presignedURL);
            
            NSURLRequest *request = [NSURLRequest requestWithURL:presignedURL];
            self.downloadTask = [self.session downloadTaskWithRequest:request];
            [self.downloadTask resume];
            
        }
        return nil;
    }];

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    NSLog(@"DownloadTask progress: %lf", progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
        self.statusLabel.text = @"Downloading...";
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:S3DownloadKeyName];
    
    //move the downloaded file to docs directory
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:filePath]
                                            error:nil];
    
    //updated UI elements
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [UIImage imageWithContentsOfFile:filePath];;
    });

}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Download Successfully";
        });
        NSLog(@"S3 DownloadTask: %@ completed successfully", task);
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Download failed";
        });
        NSLog(@"S3 DownloadTask: %@ completed with error: %@", task, [error localizedDescription]);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (double)task.countOfBytesReceived / (double)task.countOfBytesExpectedToReceive;;
    });
    
    self.downloadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundDownloadSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundDownloadSessionCompletionHandler;
        appDelegate.backgroundDownloadSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"Completion Handler has been invoked, background download task has finished.");
}





@end
