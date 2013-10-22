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

#import "Crypto.h"
#import <AWSRuntime/AWSRuntime.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation Crypto

+(NSData *)decrypt:(NSString *)data key:(NSString *)key
{
    NSData  *dataToDecrypt = [NSData dataWithBase64EncodedString:data];

    NSRange ivRange = { 0, 16 };
    NSData  *iv     = [dataToDecrypt subdataWithRange:ivRange];

    NSRange dataRange = { 16, [dataToDecrypt length] - 16 };
    NSData  *decrypt  = (NSData *)[dataToDecrypt subdataWithRange:dataRange];

    return [Crypto aes128Decrypt:decrypt key:[Crypto hexDecode:key] withIV:iv];
}

+(NSData *)aes128Decrypt:(NSData *)data key:(NSData *)key withIV:(NSData *)iv
{
    NSUInteger      dataLength = [data length];
    size_t          bufferSize = dataLength + kCCBlockSizeAES128;
    void            *buffer    = malloc(bufferSize);

    size_t          numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus       = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, [key bytes], kCCKeySizeAES128, [iv bytes], [data bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);

    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }

    free(buffer);
    return nil;
}

+(NSData *)hexDecode:(NSString *)hexString
{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char          byte_chars[3] = { '\0', '\0', '\0' };
    int           i;
    for (i = 0; i < [hexString length] / 2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i * 2];
        byte_chars[1] = [hexString characterAtIndex:i * 2 + 1];
        whole_byte    = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }

    return stringData;
}

+(NSString *)hexEncode:(NSString *)string
{
    NSUInteger len    = [string length];
    unichar    *chars = malloc(len * sizeof(unichar));

    [string getCharacters:chars];

    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        if ((int)chars[i] < 16) {
            [hexString appendString:@"0"];
        }
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);

    return hexString;
}

+(NSString *)generateRandomString
{
    unichar random[16];

    SecRandomCopyBytes(kSecRandomDefault, 16, (uint8_t *)&random);

    NSString *base = [[NSString alloc] initWithCharacters:random length:16];
    return [[Crypto hexEncode:base] substringToIndex:32];
}

@end
