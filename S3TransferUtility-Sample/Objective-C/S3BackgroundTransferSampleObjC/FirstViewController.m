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

#import "FirstViewController.h"
#import <AWSS3/AWSS3.h>
#import "Constants.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusLabel.text = @"";
        self.progressView.progress = 0;
    });
    
}

- (IBAction)start:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
          self.statusLabel.text = @"Creating a test file...";
          self.progressView.progress = 0;
      });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Create a test file in the temporary directory
        NSMutableString *dataString = [NSMutableString new];
        for (int32_t i = 1; i < 10000000; i++) {
            [dataString appendFormat:@"%d\n", i];
        }

        [self uploadData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
    });
}

- (void)uploadData:(NSData *)testData {
    //Initalize the screen elements
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 0;
        self.statusLabel.text = @"";
    });
    
    
    __weak FirstViewController *weakSelf = self;
    
    //Create the completion handler for the transfer
    AWSS3TransferUtilityUploadCompletionHandlerBlock completionHandler = ^(AWSS3TransferUtilityUploadTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                weakSelf.statusLabel.text = @"Failed to Upload";
            } else {
                weakSelf.statusLabel.text = @"Successfully Uploaded";
                weakSelf.progressView.progress = 1.0;
            }
        });
    };
    
    //Create the TransferUtility expression and add the progress block to it.
    //This would be needed to report on progress tracking
    AWSS3TransferUtilityUploadExpression *expression = [AWSS3TransferUtilityUploadExpression new];
    expression.progressBlock = ^(AWSS3TransferUtilityTask *task, NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ( weakSelf.progressView.progress < progress.fractionCompleted) {
                weakSelf.progressView.progress = progress.fractionCompleted;
            }
        });
    };

    AWSS3TransferUtility *transferUtility = [AWSS3TransferUtility defaultS3TransferUtility];
    [[transferUtility uploadData:testData
                          bucket:S3BucketName
                             key:S3UploadKeyName
                     contentType:@"text/plain"
                      expression:expression
               completionHandler:completionHandler] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error);
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
