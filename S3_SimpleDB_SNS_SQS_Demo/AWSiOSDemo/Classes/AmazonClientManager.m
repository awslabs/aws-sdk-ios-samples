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

static AmazonS3Client       *s3  = nil;
static AmazonSimpleDBClient *sdb = nil;
static AmazonSQSClient      *sqs = nil;
static AmazonSNSClient      *sns = nil;

@implementation AmazonClientManager


+(AmazonS3Client *)s3
{
    [AmazonClientManager validateCredentials];
    return s3;
}

+(AmazonSimpleDBClient *)sdb
{
    [AmazonClientManager validateCredentials];
    return sdb;
}

+(AmazonSQSClient *)sqs
{
    [AmazonClientManager validateCredentials];
    return sqs;
}

+(AmazonSNSClient *)sns
{
    [AmazonClientManager validateCredentials];
    return sns;
}

+(bool)hasCredentials
{
    return (![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"] && ![SECRET_KEY isEqualToString:@"CHANGE ME"]);
}

+(void)validateCredentials
{
    if ((sdb == nil) || (s3 == nil) || (sqs == nil) || (sns == nil)) {
        [AmazonClientManager clearCredentials];

        s3  = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
        
        sdb = [[AmazonSimpleDBClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sdb.endpoint = [AmazonEndpoints sdbEndpoint:US_WEST_2];

        sqs = [[AmazonSQSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sqs.endpoint = [AmazonEndpoints sqsEndpoint:US_WEST_2];

        sns = [[AmazonSNSClient alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
        sns.endpoint = [AmazonEndpoints snsEndpoint:US_WEST_2];
    }
}

+(void)clearCredentials
{
    [s3 release];
    [sdb release];
    [sns release];
    [sqs release];

    s3  = nil;
    sdb = nil;
    sqs = nil;
    sns = nil;
}


@end
