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

#import "AmazonKeyChainWrapper.h"
#import "AmazonTVMClient.h"

static AmazonS3Client       *s3  = nil;
static AmazonSimpleDBClient *sdb = nil;
static AmazonSQSClient      *sqs = nil;
static AmazonSNSClient      *sns = nil;
static AmazonTVMClient      *tvm = nil;

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

+(AmazonTVMClient *)tvm
{
    if (tvm == nil) {
        tvm = [[AmazonTVMClient alloc] initWithEndpoint:TOKEN_VENDING_MACHINE_URL useSSL:USE_SSL];
    }

    return tvm;
}

+(bool)hasCredentials
{
    return ![TOKEN_VENDING_MACHINE_URL isEqualToString:@"CHANGE ME"];
}

+(Response *)validateCredentials
{
    Response *ableToGetToken = [[[Response alloc] initWithCode:200 andMessage:@"OK"] autorelease];
    
    if ([AmazonKeyChainWrapper areCredentialsExpired]) {
        
        @synchronized(self)
        {
            if ([AmazonKeyChainWrapper areCredentialsExpired]) {
                
                ableToGetToken = [[AmazonClientManager tvm] anonymousRegister];
                
                if ( [ableToGetToken wasSuccessful])
                {
                    ableToGetToken = [[AmazonClientManager tvm] getToken];
                    
                    if ( [ableToGetToken wasSuccessful])
                    {
                        [AmazonClientManager initClients];
                    }
                }
            }
        }
    }
    else if ((sdb == nil) || (s3 == nil) || (sqs == nil) || (sns == nil))
    {
        @synchronized(self)
        {
            if ((sdb == nil) || (s3 == nil) || (sqs == nil) || (sns == nil))
            {
                [AmazonClientManager initClients];
            }
        }
    }
    
    return ableToGetToken;
}

+(void)initClients
{
    AmazonCredentials *credentials = [AmazonKeyChainWrapper getCredentialsFromKeyChain];
    
    [s3 release];
    s3  = [[AmazonS3Client alloc] initWithCredentials:credentials];
    s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    
    [sdb release];
    sdb = [[AmazonSimpleDBClient alloc] initWithCredentials:credentials];
    sdb.endpoint = [AmazonEndpoints sdbEndpoint:US_WEST_2];
    
    [sqs release];
    sqs = [[AmazonSQSClient alloc] initWithCredentials:credentials];
    sqs.endpoint = [AmazonEndpoints sqsEndpoint:US_WEST_2];
    
    [sns release];
    sns = [[AmazonSNSClient alloc] initWithCredentials:credentials];
    sns.endpoint = [AmazonEndpoints snsEndpoint:US_WEST_2];
}

+(void)wipeAllCredentials
{
    @synchronized(self)
    {
        [AmazonKeyChainWrapper wipeCredentialsFromKeyChain];
        
        [s3 release];
        [sdb release];
        [sns release];
        [sqs release];
        
        s3  = nil;
        sdb = nil;
        sqs = nil;
        sns = nil;
    }
}

+ (BOOL)wipeCredentialsOnAuthError:(NSError *)error
{
    id exception = [error.userInfo objectForKey:@"exception"];
    
    if([exception isKindOfClass:[AmazonServiceException class]])
    {
        AmazonServiceException *e = (AmazonServiceException *)exception;
        
        if(
           // STS http://docs.amazonwebservices.com/STS/latest/APIReference/CommonErrors.html
           [e.errorCode isEqualToString:@"IncompleteSignature"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InvalidClientTokenId"]
           || [e.errorCode isEqualToString:@"OptInRequired"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           || [e.errorCode isEqualToString:@"ServiceUnavailable"]
           
           // For S3 http://docs.amazonwebservices.com/AmazonS3/latest/API/ErrorResponses.html#ErrorCodeList
           || [e.errorCode isEqualToString:@"AccessDenied"]
           || [e.errorCode isEqualToString:@"BadDigest"]
           || [e.errorCode isEqualToString:@"CredentialsNotSupported"]
           || [e.errorCode isEqualToString:@"ExpiredToken"]
           || [e.errorCode isEqualToString:@"InternalError"]
           || [e.errorCode isEqualToString:@"InvalidAccessKeyId"]
           || [e.errorCode isEqualToString:@"InvalidPolicyDocument"]
           || [e.errorCode isEqualToString:@"InvalidToken"]
           || [e.errorCode isEqualToString:@"NotSignedUp"]
           || [e.errorCode isEqualToString:@"RequestTimeTooSkewed"]
           || [e.errorCode isEqualToString:@"SignatureDoesNotMatch"]
           || [e.errorCode isEqualToString:@"TokenRefreshRequired"]
           
           // SimpleDB http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/APIError.html
           || [e.errorCode isEqualToString:@"AccessFailure"]
           || [e.errorCode isEqualToString:@"AuthFailure"]
           || [e.errorCode isEqualToString:@"AuthMissingFailure"]
           || [e.errorCode isEqualToString:@"InternalError"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           
           // SNS http://docs.amazonwebservices.com/sns/latest/api/CommonErrors.html
           || [e.errorCode isEqualToString:@"IncompleteSignature"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InvalidClientTokenId"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           
           // SQS http://docs.amazonwebservices.com/AWSSimpleQueueService/2011-10-01/APIReference/Query_QueryErrors.html#list-of-errors
           || [e.errorCode isEqualToString:@"AccessDenied"]
           || [e.errorCode isEqualToString:@"AuthFailure"]
           || [e.errorCode isEqualToString:@"AWS.SimpleQueueService.InternalError"]
           || [e.errorCode isEqualToString:@"InternalError"]
           || [e.errorCode isEqualToString:@"InvalidAccessKeyId"]
           || [e.errorCode isEqualToString:@"InvalidSecurity"]
           || [e.errorCode isEqualToString:@"InvalidSecurityToken"]
           || [e.errorCode isEqualToString:@"MissingClientTokenId"]
           || [e.errorCode isEqualToString:@"MissingCredentials"]
           || [e.errorCode isEqualToString:@"NotAuthorizedToUseVersion"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           || [e.errorCode isEqualToString:@"X509ParseError"]
           )
        {
            [AmazonClientManager wipeAllCredentials];
            
            return YES;
        }
    }
    
    return NO;
}


@end
