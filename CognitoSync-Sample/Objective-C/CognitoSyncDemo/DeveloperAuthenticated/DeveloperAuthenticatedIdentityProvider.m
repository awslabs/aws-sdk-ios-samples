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
#import <UICKeyChainStore/UICKeyChainStore.h>

#import "Constants.h"
#import "DeveloperAuthenticatedIdentityProvider.h"
#import "DeveloperAuthenticationClient.h"

@interface DeveloperAuthenticatedIdentityProvider()

@property (strong, atomic) DeveloperAuthenticationClient *client;
@property (strong, atomic) NSString *providerName;
@property (nonatomic, strong) UICKeyChainStore *keychain;

@end

@implementation DeveloperAuthenticatedIdentityProvider

- (instancetype)initWithRegionType:(AWSRegionType)regionType
                    identityPoolId:(NSString *)identityPoolId
                      providerName:(NSString *)providerName
                        authClient:(DeveloperAuthenticationClient *)client
           identityProviderManager:(id<AWSIdentityProviderManager>)identityProviderManager {
    if (self = [super initWithRegionType:regionType
                          identityPoolId:identityPoolId
                         useEnhancedFlow:YES
                 identityProviderManager:identityProviderManager]) {
        _client = client;
        _providerName = providerName;
        _keychain = [UICKeyChainStore keyChainStoreWithService:[NSString stringWithFormat:@"%@.AmazonClientManager", [NSBundle mainBundle].bundleIdentifier]];
    }
    return self;
}

- (AWSTask<NSString *> *)token {
    if ([self.client isAuthenticated]) {
        // If the token lasts longer than the AWS temporary credentials,
        // this section should be updated to cache the token and return it if it's still valid.
        return [[self.client getToken:self.identityId logins:@{DeveloperAuthProviderName: self.keychain[BYOI_PROVIDER]}] continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.result) {
                DeveloperAuthenticationResponse *response = task.result;
                return response.token;
            } else {
                return task;
            }
        }];
    } else {
        return [AWSTask taskWithResult:nil];
    }
}

- (AWSTask<NSString *> *)getIdentityId {
    if ([self.client isAuthenticated]) {
        return [[self.client getToken:self.identityId logins:@{DeveloperAuthProviderName: self.keychain[BYOI_PROVIDER]}] continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
            if (task.result) {
                DeveloperAuthenticationResponse *response = task.result;
                self.identityId = response.identityId;
                return response.identityId;
            } else {
                return task;
            }
        }];
    } else {
        return [super getIdentityId];
    }
}

@end
