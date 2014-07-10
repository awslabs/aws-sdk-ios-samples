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

#import "Constants.h"

// TODO: Get the following Cognito constants via Cognito Console
NSString *const AWSAccountID = @"Your-AccountID";
NSString *const CognitoPoolID = @"Your-PoolID";
NSString *const CognitoRoleAuth = nil;
NSString *const CognitoRoleUnauth = @"Your-RoleUnauth";

NSString *const S3BucketName = @"Your-S3-Bucket-Name";

NSString *const S3KeyDownloadName1 = @"image1.jpg";
NSString *const S3KeyDownloadName2 = @"image2.jpg";
NSString *const S3KeyDownloadName3 = @"image3.jpg";

NSString *const S3KeyUploadName1 = @"upload1.txt";
NSString *const S3KeyUploadName2 = @"upload2.txt";
NSString *const S3KeyUploadName3 = @"upload3.txt";

NSString *const LocalFileName1 = @"downloaded-image1.jpg";
NSString *const LocalFileName2 = @"downloaded-image2.jpg";
NSString *const LocalFileName3 = @"downloaded-image3.jpg";

NSString *const StatusLabelReady = @"Ready";
NSString *const StatusLabelUploading = @"Uploading...";
NSString *const StatusLabelDownloading = @"Downloading...";
NSString *const StatusLabelFailed = @"Failed";
NSString *const StatusLabelCompleted = @"Completed";
