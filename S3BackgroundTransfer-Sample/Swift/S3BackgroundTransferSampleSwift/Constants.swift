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

import Foundation

//WARNING: To run this sample correctly, you must set the following constants.
let CognitoRegionType = AWSRegionType.Unknown
let DefaultServiceRegionType = AWSRegionType.Unknown
let CognitoIdentityPoolId: String = "YourPoolID"
let S3BucketName: String = "YourS3BucketName"
let S3DownloadKeyName: String = "YourDownloadKeyName"

let S3UploadKeyName: String = "uploadfileswift.txt"
let BackgroundSessionUploadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.uploadSession"
let BackgroundSessionDownloadIdentifier: String = "com.amazon.example.s3BackgroundTransferSwift.downloadSession"
