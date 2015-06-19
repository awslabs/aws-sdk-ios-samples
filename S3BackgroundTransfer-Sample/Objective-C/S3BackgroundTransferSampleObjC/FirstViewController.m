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

#import "FirstViewController.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"
#import "AppDelegate.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet UIProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTask;
@property (strong, nonatomic) NSURL *uploadFileURL;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:BackgroundSessionUploadIdentifier];
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
    
    if (self.uploadTask)
    {
        return;
    }
    
    // Create a test file in the temporary directory
    self.uploadFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:S3UploadKeyName]];
    NSMutableString *dataString = [NSMutableString new];
    for (int32_t i = 1; i < 2000000; i++) {
        [dataString appendFormat:@"%d\n", i];
    }
    
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.uploadFileURL.path]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.uploadFileURL.path error:&error];
    }
    [dataString writeToURL:self.uploadFileURL
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:&error];
    if (error) {
        NSLog(@"Error: %@",error);
    }
    
    
    AWSS3GetPreSignedURLRequest *getPreSignedURLRequest = [AWSS3GetPreSignedURLRequest new];
    getPreSignedURLRequest.bucket = S3BucketName;
    getPreSignedURLRequest.key = S3UploadKeyName;
    getPreSignedURLRequest.HTTPMethod = AWSHTTPMethodPUT;
    getPreSignedURLRequest.expires = [NSDate dateWithTimeIntervalSinceNow:3600];
    
    //Important: must set contentType for PUT request
    NSString *fileContentTypeStr = @"text/plain";
    getPreSignedURLRequest.contentType = fileContentTypeStr;
    
    [[[AWSS3PreSignedURLBuilder defaultS3PreSignedURLBuilder] getPreSignedURL:getPreSignedURLRequest] continueWithBlock:^id(AWSTask *task) {
        
        if (task.error) {
            NSLog(@"Error: %@",task.error);
        } else {
            
            NSURL *presignedURL = task.result;
            NSLog(@"upload presignedURL is: \n%@", presignedURL);
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:presignedURL];
            request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            [request setHTTPMethod:@"PUT"];
            [request setValue:fileContentTypeStr forHTTPHeaderField:@"Content-Type"];
            
            self.uploadTask = [self.session uploadTaskWithRequest:request fromFile:self.uploadFileURL];
            [self.uploadTask resume];
            
        }
        
        return nil;
    }];
    

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    double progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
    
    NSLog(@"UploadTask progress: %lf", progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
        self.statusLabel.text = @"Uploading...";
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Upload successfully";
        });
        NSLog(@"S3 UploadTask: %@ completed successfully", task);
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Upload failed.";
        });
        NSLog(@"S3 UploadTask: %@ completed with error: %@", task, [error localizedDescription]);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = (double)task.countOfBytesSent / (double)task.countOfBytesExpectedToSend;;
    });
    
    self.uploadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundUploadSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundUploadSessionCompletionHandler;
        appDelegate.backgroundUploadSessionCompletionHandler = nil;
        completionHandler();
    }
    
    NSLog(@"Completion Handler has been invoked, background upload task has finished.");
}


@end
