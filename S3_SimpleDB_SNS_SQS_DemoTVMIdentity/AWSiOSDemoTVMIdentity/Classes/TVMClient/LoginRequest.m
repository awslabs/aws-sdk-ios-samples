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

#import "LoginRequest.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Crypto.h"

@implementation LoginRequest

@synthesize decryptionKey;

-(id)initWithEndpoint:(NSString *)theEndpoint andUid:(NSString *)theUid andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword andAppName:(NSString *)theAppName usingSSL:(bool)usingSSL
{
    if ((self = [super init])) {
        endpoint = [theEndpoint retain];
        uid      = [theUid retain];
        username = [theUsername retain];
        password = [thePassword retain];
        appName  = [theAppName retain];
        useSSL   = usingSSL;

        self.decryptionKey = [self computeDecryptionKey];
    }

    return self;
}

-(NSString *)buildRequestUrl
{
    NSDate   *currentTime = [NSDate date];

    NSString *timestamp = [currentTime stringWithISO8601Format];
    NSData   *signature = [Crypto sha256HMac:[timestamp dataUsingEncoding:NSUTF8StringEncoding] withKey:self.decryptionKey];
    NSString *rawSig    = [[[NSString alloc] initWithData:signature encoding:NSASCIIStringEncoding] autorelease];
    NSString *hexSign   = [Crypto hexEncode:rawSig];

    return [NSString stringWithFormat:(useSSL ? SSL_LOGIN_REQUEST:LOGIN_REQUEST), endpoint, [uid stringWithURLEncoding], [username stringWithURLEncoding], [timestamp stringWithURLEncoding], [hexSign stringWithURLEncoding]];
}

-(NSString *)computeDecryptionKey
{
    NSString *salt       = [NSString stringWithFormat:@"%@%@%@", username, appName, endpoint];
    NSData   *hashedSalt = [Crypto sha256HMac:[salt dataUsingEncoding:NSUTF8StringEncoding] withKey:password];
    NSString *rawSaltStr = [[[NSString alloc] initWithData:hashedSalt encoding:NSASCIIStringEncoding] autorelease];

    return [Crypto hexEncode:rawSaltStr];
}

-(void)dealloc
{
    [endpoint release];
    [uid release];
    [username release];
    [password release];
    [appName release];
    [decryptionKey release];

    [super dealloc];
}

@end

