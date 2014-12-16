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

#import "AmazonClientManager.h"

#import <AWSRuntime/AWSRuntime.h>

#import "Constants.h"

static AmazonSESClient *ses  = nil;

@implementation AmazonClientManager


+(AmazonSESClient *)ses
{
    [AmazonClientManager validateCredentials];
    return ses;
}

+(bool)hasCredentials
{
    return (![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"] && ![SECRET_KEY isEqualToString:@"CHANGE ME"]);
}

+(void)validateCredentials
{
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
    if (ses == nil) {
        [AmazonClientManager clearCredentials];

        ses = [[AmazonSESClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        ses.endpoint = [AmazonEndpoints sesEndpoint:US_WEST_2];
    }
}

+(void)clearCredentials
{
    [ses release];
    ses = nil;
}

@end
