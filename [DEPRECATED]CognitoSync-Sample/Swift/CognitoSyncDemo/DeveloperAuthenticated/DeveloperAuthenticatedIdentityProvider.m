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

#import "Crypto.h"
#import "DeveloperAuthenticatedIdentityProvider.h"
#import "DeveloperAuthenticationClient.h"



@interface DeveloperAuthenticatedIdentityProvider()
@property (strong, atomic) DeveloperAuthenticationClient *client;
@property (strong, atomic) NSString *providerName;
@property (strong, atomic) NSString *token;
@end

@implementation DeveloperAuthenticatedIdentityProvider
@synthesize providerName=_providerName;
@synthesize token=_token;

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                        identityId:(NSString *)identityId
                    identityPoolId:(NSString *)identityPoolId
                            logins:(NSDictionary *)logins
                      providerName:(NSString *)providerName
                        authClient:(DeveloperAuthenticationClient *)client {
    if (self = [super initWithRegionType:regionType identityId:identityId accountId:nil identityPoolId:identityPoolId logins:logins]) {
        self.client = client;
        self.providerName = providerName;
    }
    return self;
}

- (BOOL)authenticatedWithProvider {
    return [self.logins objectForKey:self.providerName] != nil;
}


- (AWSTask *)getIdentityId {
    // already cached the identity id, return it
    if (self.identityId) {
        return [AWSTask taskWithResult:nil];
    }
    // not authenticated with our developer provider
    else if (![self authenticatedWithProvider]) {
        return [super getIdentityId];
    }
    // authenticated with our developer provider, use refresh logic to get id/token pair
    else {
        return [[AWSTask taskWithResult:nil] continueWithBlock:^id(AWSTask *task) {
            if (!self.identityId) {
                return [self refresh];
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
    }
}

- (AWSTask *)refresh {
    if (![self authenticatedWithProvider]) {
        // We're using the simplified flow, so just return identity id
        return [super getIdentityId];
    }
    else {
        return [[self.client getToken:self.identityId logins:self.logins] continueWithSuccessBlock:^id(AWSTask *task) {
            if (task.result) {
                DeveloperAuthenticationResponse *response = task.result;
                if (![self.identityPoolId isEqualToString:response.identityPoolId]) {
                    return [AWSTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                                     code:DeveloperAuthenticationClientInvalidConfig
                                                                 userInfo:nil]];
                }
                
                // potential for identity change here
                self.identityId = response.identityId;
                self.token = response.token;
            }
            return [AWSTask taskWithResult:self.identityId];
        }];
    }
}


            
@end
