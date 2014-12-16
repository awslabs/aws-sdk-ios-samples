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

#import "LoginResponseHandler.h"
#import "LoginResponse.h"
#import "Crypto.h"
#import "JSONUtilities.h"

@implementation LoginResponseHandler

-(id)initWithKey:(NSString *)theKey
{
    if ((self = [super init])) {
        decryptionKey = [theKey retain];
    }

    return self;
}

-(Response *)handleResponse:(int)responseCode body:(NSString *)responseBody
{
    if (responseCode == 200) {
        NSData   *body = [Crypto decrypt:responseBody key:[decryptionKey substringToIndex:32]];
        NSString *json = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
        NSString *key  = [JSONUtilities getJSONElement:json element:@"key"];

        return [[[LoginResponse alloc] initWithKey:key] autorelease];
    }
    else {
        return [[[LoginResponse alloc] initWithCode:responseCode andMessage:responseBody] autorelease];
    }
}

-(void)dealloc
{
    [decryptionKey release];
    [super dealloc];
}

@end

