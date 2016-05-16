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
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *cachedLogins;

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
        // `- getToken:logins:` should be updated to cache `token` and return it if `token` is not expired and `logins` hasn't changed.
        return [[[self getLogins] continueWithSuccessBlock:^id _Nullable(AWSTask<NSDictionary<NSString *,NSString *> *> * _Nonnull task) {
            NSDictionary<NSString *,NSString *> *logins = task.result;
            return [self.client getToken:self.identityId logins:logins];
        }] continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
            DeveloperAuthenticationResponse *response = task.result;
            return response.token;
        }];
    } else {
        return [super token];
    }
}

- (AWSTask<NSString *> *)getIdentityId {
    if ([self.client isAuthenticated]) {
        return [[self getLogins] continueWithSuccessBlock:^id _Nullable(AWSTask<NSDictionary<NSString *,NSString *> *> * _Nonnull task) {
            NSDictionary<NSString *,NSString *> *logins = task.result;

            // If `logins` hasn't changed, return cached `identityId`. If `- getToken:logins:` is updated to return cached `logins, you can remove this check and delegate it to `DeveloperAuthenticationClient`.
            if (self.identityId
                && [self.cachedLogins isEqualToDictionary:logins]) {
                return self.identityId;
            }
            self.cachedLogins = logins;

            return [[self.client getToken:self.identityId logins:logins] continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
                DeveloperAuthenticationResponse *response = task.result;
                self.identityId = response.identityId;
                return response.identityId;
            }];
        }];
    } else {
        return [super getIdentityId];
    }
}

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins {
    if (![self.client isAuthenticated]) {
        if (self.identityProviderManager) {
            return [self.identityProviderManager logins];
        } else {
            return [AWSTask taskWithResult:nil];
        }
    } else {
        return [[self token] continueWithSuccessBlock:^id _Nullable(AWSTask<NSString *> * _Nonnull task) {
            if (!task.result) {
                return [AWSTask taskWithResult:nil];
            }
            NSString *token = task.result;
            return [AWSTask taskWithResult:@{self.identityProviderName : token}];
        }];
    }
}

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)getLogins {
    AWSTask *task = [AWSTask taskWithResult:nil];
    if (self.identityProviderManager) {
        task = [self.identityProviderManager logins];
    }
    return [task continueWithSuccessBlock:^id _Nullable(AWSTask * _Nonnull task) {
        NSMutableDictionary<NSString *, NSString *> *mutableLogins = [NSMutableDictionary new];
        if (task.result) {
            [mutableLogins addEntriesFromDictionary:task.result];
        }

        [mutableLogins setObject:self.keychain[BYOI_PROVIDER] forKey:DeveloperAuthProviderName];

        return [NSDictionary dictionaryWithDictionary:mutableLogins];
    }];
}

@end
