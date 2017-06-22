/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 * http://aws.amazon.com/apache2.0
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

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (copy, nonatomic) AWSS3TransferUtilityDownloadCompletionHandlerBlock completionHandler;
@property (copy, nonatomic) AWSS3TransferUtilityProgressBlock progressBlock;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.progressView.progress = 0;
    self.statusLabel.text = @"Ready";

    __weak SecondViewController *weakSelf = self;
    self.completionHandler = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.statusLabel.text = @"Failed to Download";
            }
            if (data) {
                weakSelf.statusLabel.text = @"Successfully Downloaded";
                weakSelf.imageView.image = [UIImage imageWithData:data];
                weakSelf.progressView.progress = 1.0;
            }
        });
    };

    self.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress.fractionCompleted;
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [transferUtility enumerateToAssignBlocksForUploadTask:nil downloadTask:^(AWSS3TransferUtilityDownloadTask * _Nonnull downloadTask, AWSS3TransferUtilityProgressBlock  _Nullable __autoreleasing * _Nullable downloadProgressBlockReference, AWSS3TransferUtilityDownloadCompletionHandlerBlock  _Nullable __autoreleasing * _Nullable completionHandlerReference) {
        NSLog(@"%lu", (unsigned long)downloadTask.taskIdentifier);

        *downloadProgressBlockReference = weakSelf.progressBlock;
        *completionHandlerReference = weakSelf.completionHandler;

        dispatch_async(dispatch_get_main_queue(), ^{
            self.statusLabel.text = @"Uploading...";
        });
    }];
}

- (IBAction)start:(id)sender {
    self.imageView.image = nil;

    AWSS3TransferUtilityDownloadExpression *expression = [AWSS3TransferUtilityDownloadExpression new];
    expression.progressBlock = self.progressBlock;

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility downloadDataFromBucket:S3BucketName
                                         key:S3DownloadKeyName
                                  expression:expression
                           completionHandler:self.completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.statusLabel.text = @"Downloading...";
            });
        }

        return nil;
    }];
}

@end
