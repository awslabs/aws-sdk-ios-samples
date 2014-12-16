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

#import <AWSRuntime/AWSRuntime.h>

@interface AmazonKeyChainWrapper:NSObject {
}

+(bool)areCredentialsExpired;
+(AmazonCredentials *)getCredentialsFromKeyChain;
+(void)storeCredentialsInKeyChain:(NSString *)theAccessKey secretKey:(NSString *)theSecretKey securityToken:(NSString *)theSecurityToken expiration:(NSString *)theExpirationDate;

+(NSString *)getValueFromKeyChain:(NSString *)key;
+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key;

+(void)registerDeviceId:(NSString *)uid andKey:(NSString *)key;
+(NSString *)getUidForDevice;
+(NSString *)getKeyForDevice;

+(NSDate *)convertStringToDate:(NSString *)expiration;
+(bool)isExpired:(NSDate *)date;

+(OSStatus)wipeKeyChain;
+(OSStatus)wipeCredentialsFromKeyChain;
+(NSMutableDictionary *)createKeychainDictionaryForKey:(NSString *)key;

@end
