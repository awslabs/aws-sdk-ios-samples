/*
 Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */

#import "FirstViewController.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (copy, nonatomic) AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler;
@property (copy, nonatomic) AWSS3TransferUtilityUploadProgressBlock uploadProgress;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.progressView.progress = 0;
    self.statusLabel.text = @"Ready";

    __weak FirstViewController *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.statusLabel.text = @"Failed to Upload";
            } else {
                weakSelf.statusLabel.text = @"Successfully Uploaded";
                weakSelf.progressView.progress = 1.0;
            }
        });
    };

    self.uploadProgress = ^(AWSS3TransferUtilityTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = (double)totalBytesSent / (double)totalBytesExpectedToSend;
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility
     enumerateToAssignBlocksForUploadTask:^(AWSS3TransferUtilityUploadTask *uploadTask, __autoreleasing AWSS3TransferUtilityUploadProgressBlock *uploadProgressBlockReference, __autoreleasing AWSS3TransferUtilityUploadCompletionHandlerBlock *completionHandlerReference) {
         NSLog(@"%lu", (unsigned long)uploadTask.taskIdentifier);

         *uploadProgressBlockReference = weakSelf.uploadProgress;
         *completionHandlerReference = weakSelf.completionHandler;

         dispatch_async(dispatch_get_main_queue(), ^{
             self.statusLabel.text = @"Uploading...";
         });
     }
     downloadTask:nil];
}

- (IBAction)start:(id)sender {
    // Create a test file in the temporary directory
    NSMutableString *dataString = [NSMutableString new];
    for (int32_t i = 1; i < 10000000; i++) {
        [dataString appendFormat:@"%d\n", i];
    }

    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.uploadProgress = self.uploadProgress;

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility uploadData:[dataString dataUsingEncoding:NSUTF8StringEncoding]
                          bucket:S3BucketName
                             key:S3UploadKeyName
                     contentType:@"text/plain"
                      expression:expression
                completionHander:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.exception) {
            NSLog(@"Exception: %@", task.exception);
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"Uploading...";
            });
        }

        return nil;
    }];
}

@end
