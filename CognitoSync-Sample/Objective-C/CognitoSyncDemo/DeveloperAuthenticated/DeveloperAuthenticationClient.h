/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const LoginURI;
FOUNDATION_EXPORT NSString *const GetTokenURI;
FOUNDATION_EXPORT NSString *const DeveloperAuthenticationClientDomain;
typedef NS_ENUM(NSInteger, DeveloperAuthenticationClientErrorType) {
    DeveloperAuthenticationClientInvalidConfig,
    DeveloperAuthenticationClientDecryptError,
    DeveloperAuthenticationClientLoginError,
    DeveloperAuthenticationClientUnknownError,
};

@class BFTask;

@interface DeveloperAuthenticationResponse : NSObject

@property (nonatomic, strong, readonly) NSString *identityId;
@property (nonatomic, strong, readonly) NSString *identityPoolId;
@property (nonatomic, strong, readonly) NSString *token;

@end

@interface DeveloperAuthenticationClient : NSObject

@property (nonatomic, strong) NSString *appname;
@property (nonatomic, strong) NSString *endpoint;

+ (instancetype)identityProviderWithAppname:(NSString *)appname endpoint:(NSString *)endpoint;
- (instancetype)initWithAppname:(NSString *)appname endpoint:(NSString *)endpoint;

- (BOOL)isAuthenticated;
- (BFTask *)getToken:identityId logins:(NSDictionary *)logins;
- (BFTask *)login:(NSString *)username password:(NSString *)password;
- (void)logout;

@end
