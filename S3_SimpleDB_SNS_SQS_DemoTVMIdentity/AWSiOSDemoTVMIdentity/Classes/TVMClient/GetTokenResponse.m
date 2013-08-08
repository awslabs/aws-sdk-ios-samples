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

#import "GetTokenResponse.h"

@implementation GetTokenResponse

@synthesize accessKey;
@synthesize secretKey;
@synthesize securityToken;
@synthesize expirationDate;

-(id)initWithAccessKey:(NSString *)theAccessKey andSecretKey:(NSString *)theSecurityKey andSecurityToken:(NSString *)theSecurityToken andExpirationDate:(NSString *)theExpirationDate
{
    if ((self = [super initWithCode:200 andMessage:nil])) {
        self.accessKey      = theAccessKey;
        self.secretKey      = theSecurityKey;
        self.securityToken  = theSecurityToken;
        self.expirationDate = theExpirationDate;
    }

    return self;
}

-(void)dealloc
{
    [accessKey release];
    [secretKey release];
    [securityToken release];
    [expirationDate release];

    [super dealloc];
}

@end

