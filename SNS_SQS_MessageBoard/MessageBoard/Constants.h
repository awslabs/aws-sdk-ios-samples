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


//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// This sample App is for demonstration purposes only.
// It is not secure to embed your credentials into source code.
// Please read the following article for getting credentials
// to devices securely.
// http://aws.amazon.com/articles/Mobile/4611615499399490
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#define ACCESS_KEY_ID                   @"CHANGE ME"
#define SECRET_KEY                      @"CHANGE ME"
#define CONFIRM_SUBSCRIPTION_MESSAGE    @"A confirmation must be accepted before messages are received."
#define QUEUE_NOTICE                    @"It may take a few minutes before the queue starts receiving messages."
#define SMS_SUBSCRIPTION_MESSAGE        @"SMS Subscritions must include country codes.  1 for US phones."
#define CREDENTIALS_MESSAGE             @"AWS Credentials not configured correctly.  Please review the README file."
#define PLATFORM_APPLICATION_ARN_MESSAGE @"Platform Application ARN is not configured correctly. please review the README file."

#define TOPIC_NAME                      @"MessageBoard"
#define QUEUE_NAME                      @"message-board-queue"

#define PLATFORM_APPLICATION_ARN        @"CHANGE ME"

@interface Constants:NSObject {
}

+(UIAlertView *)confirmationAlert;
+(UIAlertView *)queueAlert;
+(UIAlertView *)smsSubscriptionAlert;
+(UIAlertView *)credentialsAlert;
+(UIAlertView *)platformApplicationARNAlert;
+(UIAlertView *)universalAlertsWithTitle:(NSString*)title andMessage:(NSString*)message;
@end
