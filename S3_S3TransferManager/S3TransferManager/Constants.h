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

#import <Foundation/Foundation.h>

// Constants used to represent your AWS Credentials.
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This sample App is for demonstration purposes only.
// It is not secure to embed your credentials into source code.
// DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.
// We offer two solutions for getting credentials to your mobile App.
// Please read the following article to learn about Token Vending Machine:
// * http://aws.amazon.com/articles/Mobile/4611615499399490
// Or consider using web identity federation:
// * http://aws.amazon.com/articles/Mobile/4617974389850313
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#define ACCESS_KEY_ID          @"CHANGE ME"
#define SECRET_KEY             @"CHANGE ME"


// Constants for the Bucket
#define S3TRANSFERMANAGER_BUCKET         @"s3-transfer-manager-bucket"


#define CREDENTIALS_ERROR_TITLE    @"Missing Credentials"
#define CREDENTIALS_ERROR_MESSAGE  @"AWS Credentials not configured correctly.  Please review the README file."

#define kRequestTagForSmallFile         @"tag-tm-small-file-0"
#define kRequestTagForBigFile           @"tag-tm-big-file-0"
#define kKeyForBigFile                  @"tm-large-file-0"
#define kKeyForSmallFile                @"tm-small-file-0"

#define kSmallFileSize 1024*1024*4.8 //4.8 megs
#define kBigFileSize 1024*1024*10  //10 megs

@interface Constants : NSObject

/*
 * Creating bucket
 */
+ (NSString *)transferManagerBucket;

@end
