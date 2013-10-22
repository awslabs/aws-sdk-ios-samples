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

#import "AmazonKeyChainWrapper.h"
#import "AmazonTVMClient.h"

static AmazonCredentials *credentials = nil;
static AmazonTVMClient *tvm = nil;

// This DynamoDB client object is used for operations that are not supported by the Persistence Framework. eg. Create tables
static AmazonDynamoDBClient *ddb = nil;


@implementation AmazonClientManager

#pragma mark - AmazonCredentialsProvider

- (AmazonCredentials *)credentials;
{
    [AmazonClientManager validateCredentials];
    return credentials;
}

- (void)refresh
{
    [AmazonClientManager wipeAllCredentials];
    [AmazonClientManager validateCredentials];
}

#pragma mark -

+ (AmazonDynamoDBClient *)ddb
{
    [AmazonClientManager validateCredentials];
    return ddb;
}

+ (AmazonTVMClient *)tvm
{
    if (tvm == nil) {
        tvm = [[AmazonTVMClient alloc] initWithEndpoint:TOKEN_VENDING_MACHINE_URL useSSL:USE_SSL];
    }
    
    return tvm;
}

+ (bool)hasCredentials
{
    return ![TOKEN_VENDING_MACHINE_URL isEqualToString:@"CHANGE ME"];
}

+ (Response *)validateCredentials
{
    Response *ableToGetToken = [[Response alloc] initWithCode:200 andMessage:@"OK"];
    
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
                        [AmazonClientManager setupClients];
                    }
                }
            }
        }
    }
    else if (ddb == nil)
    {
        @synchronized(self)
        {
            if (ddb == nil)
            {
                [AmazonClientManager setupClients];
            }
        }
    }
    
    return ableToGetToken;
}

+ (void)setupClients
{
    credentials = [AmazonKeyChainWrapper getCredentialsFromKeyChain];
    ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    ddb.endpoint = [AmazonEndpoints ddbEndpoint:US_WEST_2];
}

+ (void)wipeAllCredentials
{
    @synchronized(self)
    {
        [AmazonKeyChainWrapper wipeCredentialsFromKeyChain];
        ddb = nil;
    }
}

@end
