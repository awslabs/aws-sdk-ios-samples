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

#import <UIKit/UIKit.h>

@interface S3NSOperationDemoViewController:UIViewController
{
    IBOutlet UIImageView     *uploadImage1;
    IBOutlet UIImageView     *uploadImage2;
    IBOutlet UIImageView     *uploadImage3;
    IBOutlet UIImageView     *downloadImage1;
    IBOutlet UIImageView     *downloadImage2;
    IBOutlet UIImageView     *downloadImage3;

    IBOutlet UIProgressView  *uploadProgress1;
    IBOutlet UIProgressView  *uploadProgress2;
    IBOutlet UIProgressView  *uploadProgress3;
    IBOutlet UIProgressView  *downloadProgress1;
    IBOutlet UIProgressView  *downloadProgress2;
    IBOutlet UIProgressView  *downloadProgress3;

    IBOutlet UIButton        *uploadButton;
    IBOutlet UIButton        *donwloadButton;

    IBOutlet UIBarButtonItem *done;
    IBOutlet UIBarButtonItem *cleanUp;

    NSOperationQueue         *operationQueue;
}

-(IBAction)uploadImages:(id)sender;
-(IBAction)downloadImages:(id)sender;

@end
