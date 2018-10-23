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


@interface Crypto:NSObject {
}

+(NSData *)decrypt:(NSString *)data key:(NSString *)key;
+(NSData *)aes128Decrypt:(NSData *)data key:(NSData *)key withIV:(NSData *)iv;

+(NSData *)hexDecode:(NSString *)hexString;
+(NSString *)hexEncode:(NSString *)string;

+(NSData *)sha256HMac:(NSData *)data withKey:(NSString *)key;

+(NSString *)generateRandomString;

@end
