/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "AmazonKeyChainWrapper.h"
#import <AWSRuntime/AWSRuntime.h>

NSString *kKeychainUsernameIdentifier;

@implementation AmazonKeyChainWrapper

+(void)initialize 
{
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier;

    kKeychainUsernameIdentifier = [[NSString stringWithFormat:@"%@.USERNAME", bundleID] retain]; 
}

+(void)storeUsername:(NSString *)theUsername
{
    [AmazonKeyChainWrapper storeValueInKeyChain:theUsername forKey:kKeychainUsernameIdentifier];    
}

+(NSString *)username
{
    return [AmazonKeyChainWrapper getValueFromKeyChain:kKeychainUsernameIdentifier];
}

+(NSString *)getValueFromKeyChain:(NSString *)key
{
    AMZLogDebug(@"Get Value for KeyChain key:[%@]", key);

    NSMutableDictionary *queryDictionary = [[[NSMutableDictionary alloc] init] autorelease];

    [queryDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrGeneric];
    [queryDictionary setObject:(id) kCFBooleanTrue forKey:(id)kSecReturnAttributes];
    [queryDictionary setObject:(id) kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    [queryDictionary setObject:(id) kCFBooleanTrue forKey:(id)kSecReturnData];
    [queryDictionary setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];

    NSDictionary *returnedDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    OSStatus     keychainError       = SecItemCopyMatching((CFDictionaryRef)queryDictionary, (CFTypeRef *)&returnedDictionary);
    if (keychainError == errSecSuccess)
    {
        NSData *rawData = [returnedDictionary objectForKey:(id)kSecValueData];
        return [[[NSString alloc] initWithBytes:[rawData bytes] length:[rawData length] encoding:NSUTF8StringEncoding] autorelease];
    }
    else
    {
        AMZLogDebug(@"Unable to fetch value for keychain key '%@', Error Code: %ld", key, keychainError);
        return nil;
    }
}

+(void)storeValueInKeyChain:(NSString *)value forKey:(NSString *)key
{
    AMZLogDebug(@"Storing value:[%@] in KeyChain as key:[%@]", value, key);

    NSMutableDictionary *keychainDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    [keychainDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)kSecAttrGeneric];
    [keychainDictionary setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];
    [keychainDictionary setObject:[value dataUsingEncoding:NSUTF8StringEncoding]    forKey:(id)kSecValueData];
    [keychainDictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)kSecAttrAccount];
    [keychainDictionary setObject:(id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(id)kSecAttrAccessible];

    OSStatus keychainError = SecItemAdd((CFDictionaryRef)keychainDictionary, NULL);
    if (keychainError == errSecDuplicateItem) {
        SecItemDelete((CFDictionaryRef)keychainDictionary);
        keychainError = SecItemAdd((CFDictionaryRef)keychainDictionary, NULL);
    }
    
    if (keychainError != errSecSuccess) {
        AMZLogDebug(@"Error saving value to keychain key '%@', Error Code: %ld", key, keychainError);
    }
}

+(OSStatus)wipeKeyChain
{
    OSStatus keychainError = SecItemDelete((CFDictionaryRef)[AmazonKeyChainWrapper createKeychainDictionaryForKey : kKeychainUsernameIdentifier]);
    if(keychainError != errSecSuccess && keychainError != errSecItemNotFound)
    {
        AMZLogDebug(@"Keychain Key: kKeychainUsernameIdentifier, Error Code: %ld", keychainError);
        return keychainError;
    }
    
    return errSecSuccess;
}

+(NSMutableDictionary *)createKeychainDictionaryForKey:(NSString *)key
{
    NSMutableDictionary *dictionary = [[[NSMutableDictionary alloc] init] autorelease];

    [dictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)kSecAttrGeneric];
    [dictionary setObject:(id) kSecClassGenericPassword forKey:(id)kSecClass];
    [dictionary setObject:[key dataUsingEncoding:NSUTF8StringEncoding]      forKey:(id)kSecAttrAccount];
    [dictionary setObject:(id) kSecAttrAccessibleWhenUnlockedThisDeviceOnly forKey:(id)kSecAttrAccessible];

    return dictionary;
}

@end
