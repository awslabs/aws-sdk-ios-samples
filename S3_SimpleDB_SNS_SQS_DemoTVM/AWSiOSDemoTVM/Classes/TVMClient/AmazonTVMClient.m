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

#import "AmazonTVMClient.h"
#import "AmazonKeyChainWrapper.h"
#import <AWSRuntime/AWSRuntime.h>

#import "RequestDelegate.h"

#import "GetTokenResponseHandler.h"
#import "GetTokenRequest.h"
#import "GetTokenResponse.h"

#import "RegisterDeviceRequest.h"

#import "Crypto.h"

@implementation AmazonTVMClient

@synthesize endpoint, useSSL;

-(id)initWithEndpoint:(NSString *)theEndpoint useSSL:(bool)usingSSL;
{
    if ((self = [super init])) {
        self.endpoint = [self getEndpointDomain:[theEndpoint lowercaseString]];
        self.useSSL   = usingSSL;
    }

    return self;
}

-(Response *)anonymousRegister
{
    Response *response = [[[Response alloc] initWithCode:200 andMessage:@"OK"] autorelease];

    if ( [AmazonKeyChainWrapper getUidForDevice] == nil) {
        NSString              *uid = [Crypto generateRandomString];
        NSString              *key = [Crypto generateRandomString];

        RegisterDeviceRequest *request = [[[RegisterDeviceRequest alloc] initWithEndpoint:self.endpoint andUid:uid andKey:key usingSSL:self.useSSL] autorelease];
        ResponseHandler       *handler = [[[ResponseHandler alloc] init] autorelease];

        response = [self processRequest:request responseHandler:handler];
        if ( [response wasSuccessful]) {
            [AmazonKeyChainWrapper registerDeviceId:uid andKey:key];
        }
        else {
            AMZLogDebug(@"Token Vending Machine responded with Code: [%d] and Messgae: [%@]", response.code, response.message);
        }
    }

    return response;
}

-(Response *)getToken
{
    NSString         *uid = [AmazonKeyChainWrapper getUidForDevice];
    NSString         *key = [AmazonKeyChainWrapper getKeyForDevice];

    Request          *request = [[[GetTokenRequest alloc] initWithEndpoint:self.endpoint andUid:uid andKey:key usingSSL:self.useSSL] autorelease];
    ResponseHandler  *handler = [[[GetTokenResponseHandler alloc] initWithKey:key] autorelease];

    GetTokenResponse *response = (GetTokenResponse *)[self processRequest:request responseHandler:handler];

    if ( [response wasSuccessful]) {
        [AmazonKeyChainWrapper storeCredentialsInKeyChain:response.accessKey secretKey:response.secretKey securityToken:response.securityToken expiration:response.expirationDate];
    }
    else {
        AMZLogDebug(@"Token Vending Machine responded with Code: [%d] and Messgae: [%@]", response.code, response.message);
    }

    return response;
}

-(Response *)processRequest:(Request *)request responseHandler:(ResponseHandler *)handler
{
    int             retries   = 2;
    RequestDelegate *delegate = [[[RequestDelegate alloc] init] autorelease];

    do {
        AMZLogDebug(@"Request URL: %@", [request buildRequestUrl]);

        NSURL             *url        = [[[NSURL alloc] initWithString:[request buildRequestUrl]] autorelease];
        NSURLRequest      *theRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        NSError           *error      = nil;
        NSHTTPURLResponse *response   = nil;

        NSData            *data       = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];

        if (error == nil)
        {
            return [handler handleResponse:response.statusCode body:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
        }
    } while (delegate.failed && retries-- > 0);

    return [[[Response alloc] initWithCode:500 andMessage:delegate.responseBody] autorelease];
}

-(NSString *)getEndpointDomain:(NSString *)originalEndpoint
{
    NSRange endpointRange;

    if ( [originalEndpoint hasPrefix:@"http://"] || [originalEndpoint hasPrefix:@"https://"]) {
        NSRange startOfDomain = [originalEndpoint rangeOfString:@"://"];
        endpointRange.location = startOfDomain.location + 3;
    }
    else {
        endpointRange.location = 0;
    }

    if ( [originalEndpoint hasSuffix:@"/"]) {
        endpointRange.length = ([originalEndpoint length] - 1) - endpointRange.location;
    }
    else {
        endpointRange.length = [originalEndpoint length] - endpointRange.location;
    }

    return [originalEndpoint substringWithRange:endpointRange];
}

-(void)dealloc
{
    [endpoint release];
    [super dealloc];
}

@end
