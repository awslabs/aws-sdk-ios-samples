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

#import "Response.h"

@interface GetTokenResponse:Response {
    NSString *accessKey;
    NSString *secretKey;
    NSString *securityToken;
    NSString *expirationDate;
}

@property (nonatomic) NSString *accessKey;
@property (nonatomic) NSString *secretKey;
@property (nonatomic) NSString *securityToken;
@property (nonatomic) NSString *expirationDate;

-(id)initWithAccessKey:(NSString *)theAccessKey andSecretKey:(NSString *)theSecurityKey andSecurityToken:(NSString *)theSecurityToken andExpirationDate:(NSString *)theExpirationDate;

@end
