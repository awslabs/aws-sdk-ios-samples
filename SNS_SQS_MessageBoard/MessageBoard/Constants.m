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

#import "Constants.h"

@implementation Constants


+(UIAlertView *)confirmationAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"Confirmation Required" message:CONFIRM_SUBSCRIPTION_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(UIAlertView *)queueAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"Message Queue" message:QUEUE_NOTICE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(UIAlertView *)smsSubscriptionAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"SMS Validation" message:SMS_SUBSCRIPTION_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

+(UIAlertView *)credentialsAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"Missing Credentials" message:CREDENTIALS_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
}

@end
