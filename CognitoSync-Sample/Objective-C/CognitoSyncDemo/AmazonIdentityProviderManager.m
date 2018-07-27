/*
 * Copyright 2016 BJSS, Inc. or its affiliates. All Rights Reserved.
 *
 * Created by Andrea Scuderi on 08/09/2016.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  https://github.com/bjss/aws-sdk-ios-samples/blob/master/LICENSE
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonIdentityProviderManager.h"

@implementation AmazonIdentityProviderManager
{
    NSDictionary<NSString *, NSString *> *loginCache;

}

+ (AmazonIdentityProviderManager *)sharedInstance
{
    static AmazonIdentityProviderManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AmazonIdentityProviderManager new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]){
        loginCache = [[NSDictionary<NSString *, NSString *> alloc] init];
    }
    return self;
}

- (AWSTask<NSDictionary<NSString *, NSString *> *> *)logins {
    
    AWSTask *task = [AWSTask taskWithResult:loginCache];
    return task;
}

- (void)mergeLogins:(NSDictionary<NSString *,NSString *> *)logins {
    
    
    NSMutableDictionary<NSString *, NSString *> *merge = [[NSMutableDictionary<NSString *, NSString *> alloc] init];
    merge = [loginCache mutableCopy];
    
    for (NSString* key in logins) {
        merge[key] = logins[key];
    }
    loginCache = [merge copy];
}

- (void)reset {
    loginCache = [[NSDictionary<NSString *, NSString *> alloc] init];
}

@end
