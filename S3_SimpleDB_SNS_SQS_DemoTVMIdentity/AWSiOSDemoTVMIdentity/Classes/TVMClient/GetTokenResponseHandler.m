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

#import "GetTokenResponseHandler.h"
#import "GetTokenResponse.h"
#import "Crypto.h"
#import "JSONUtilities.h"

@implementation GetTokenResponseHandler

-(id)initWithKey:(NSString *)theKey
{
    if ((self = [super init])) {
        key = [theKey retain];
    }

    return self;
}

-(Response *)handleResponse:(int)responseCode body:(NSString *)responseBody
{
    if (responseCode == 200) {
        NSData   *body = [Crypto decrypt:responseBody key:key];
        NSString *json = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];

        NSString *accessKey      = [JSONUtilities getJSONElement:json element:@"accessKey"];
        NSString *secretKey      = [JSONUtilities getJSONElement:json element:@"secretKey"];
        NSString *securityToken  = [JSONUtilities getJSONElement:json element:@"securityToken"];
        NSString *expirationDate = [JSONUtilities getJSONElement:json element:@"expirationDate"];
        
        [json release];

        return [[[GetTokenResponse alloc] initWithAccessKey:accessKey andSecretKey:secretKey andSecurityToken:securityToken andExpirationDate:expirationDate] autorelease];
    }
    else {
        return [[[GetTokenResponse alloc] initWithCode:responseCode andMessage:responseBody] autorelease];
    }
}

-(void)dealloc
{
    [key release];
    [super dealloc];
}

@end

