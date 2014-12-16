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

#import "Request.h"

#define LOGIN_REQUEST        @"http://%@/login?uid=%@&username=%@&timestamp=%@&signature=%@"
#define SSL_LOGIN_REQUEST    @"https://%@/login?uid=%@&username=%@&timestamp=%@&signature=%@"

@interface LoginRequest:Request {
    NSString *endpoint;
    NSString *uid;
    NSString *username;
    NSString *password;
    NSString *appName;
    bool     useSSL;

    NSString *decryptionKey;
}

@property (nonatomic, retain) NSString *decryptionKey;

-(id)initWithEndpoint:(NSString *)theEndpoint andUid:(NSString *)theUid andUsername:(NSString *)theUsername andPassword:(NSString *)thePassword andAppName:(NSString *)theAppName usingSSL:(bool)usingSSL;
-(NSString *)computeDecryptionKey;

@end
