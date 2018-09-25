/*
 * Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 0;
        self.statusLabel.text = @"";
    });
    

}

- (IBAction)start:(id)sender {
    
    //Initalize the screen elements
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 0;
        self.statusLabel.text = @"";
        self.imageView.image = nil;
    });
    
    __weak SecondViewController *weakSelf = self;

    //Create the completion handler for the transfer
    AWSS3TransferUtilityDownloadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityDownloadTask *task, NSURL *location, NSData *data, NSError *error) {
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
    
    
    //Create the TransferUtility expression and add the progress block to it.
    //This would be needed to report on progress tracking
    AWSS3TransferUtilityDownloadExpression *expression = [AWSS3TransferUtilityDownloadExpression new];
    expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressView.progress = progress.fractionCompleted;
        });
    };

   
    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility downloadDataFromBucket:S3BucketName
                                         key:S3DownloadKeyName
                                  expression:expression
                           completionHandler:completionHandler] continueWithBlock:^id(AWSTask *task) {
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
