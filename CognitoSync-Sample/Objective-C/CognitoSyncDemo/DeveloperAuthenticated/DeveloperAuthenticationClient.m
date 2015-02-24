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

#import "DeveloperAuthenticationClient.h"
#import "Crypto.h"
#import "AWSCore.h"
#import "UICKeychainStore.h"

NSString *const ProviderPlaceHolder = @"foobar.com";
NSString *const LoginURI = @"%@/login?uid=%@&username=%@&timestamp=%@&signature=%@";
NSString *const GetTokenURI = @"%@/gettoken?uid=%@&timestamp=%@%@&signature=%@";
NSString *const DeveloperAuthenticationClientDomain = @"com.amazonaws.service.cognitoidentity.DeveloperAuthenticatedIdentityProvider";
NSString *const UidKey = @"uid";
NSString *const EncryptionKeyKey = @"authkey";

@interface DeveloperAuthenticationResponse()

@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *token;

@end

@implementation DeveloperAuthenticationResponse
@end

@interface DeveloperAuthenticationClient()
@property (nonatomic, strong) NSString *identityPoolId;
@property (nonatomic, strong) NSString *identityId;
@property (nonatomic, strong) NSString *token;

// used for internal encryption
@property (nonatomic, strong) NSString *uid;
@property (nonatomic, strong) NSString *key;

// used to save state of authentication
@property (nonatomic, strong) UICKeyChainStore *keychain;

@end

@implementation DeveloperAuthenticationClient

+ (instancetype)identityProviderWithAppname:(NSString *)appname endpoint:(NSString *)endpoint {
    return [[DeveloperAuthenticationClient alloc] initWithAppname:appname endpoint:endpoint];
}

- (instancetype)initWithAppname:(NSString *)appname endpoint:(NSString *)endpoint {
    if (self = [super init]) {
        self.appname  = appname;
        self.endpoint = endpoint;
        
        self.keychain = _keychain = [UICKeyChainStore keyChainStoreWithService:[NSString stringWithFormat:@"%@.%@.%@", [NSBundle mainBundle].bundleIdentifier, [DeveloperAuthenticationClient class], self.appname]];
        
        self.uid = self.keychain[UidKey];
        self.key = self.keychain[EncryptionKeyKey];
    }
    
    return self;
}

- (BOOL)isAuthenticated {
    return self.key != nil;
}

// login and get a decryption key to be used for subsequent calls
- (BFTask *)login:(NSString *)username password:(NSString *)password {
    
    // If the key is already set, the login already succeeeded
    if (self.key) {
        return [BFTask taskWithResult:self.key];
    }
    
    if (self.uid == nil) {
        // generate a session id for communicating with backend
        self.uid = [Crypto generateRandomString];
    }
    
    return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        NSURL *request = [NSURL URLWithString:[self buildLoginRequestUrl:username password:password]];
        NSData *rawResponse = [NSData dataWithContentsOfURL:request];
        if (!rawResponse) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientLoginError
                                                         userInfo:nil]];
        }
        
        NSString *response = [[NSString alloc] initWithData:rawResponse encoding:NSUTF8StringEncoding];
        AWSLogDebug(@"response: %@", response);
        NSString *key = [[self computeDecryptionKey:username password:password] substringToIndex:32];
        NSData *body = [Crypto decrypt:response key:key];
        if (!body) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientDecryptError
                                                         userInfo:nil]];
        }
        
        NSString *json = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSLog(@"json: %@", json);
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:nil];
        self.key = [jsonDict objectForKey:@"key"];
        if (!self.key) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientUnknownError
                                                         userInfo:nil]];
        }
        AWSLogDebug(@"key: %@", self.key);
        
        // Save our key/uid to the keychain
        self.keychain[UidKey] = self.uid;
        self.keychain[EncryptionKeyKey] = self.key;
        
        return [BFTask taskWithResult:nil];
    }];
    
}

- (void)logout {
    self.key = nil;
    self.keychain[EncryptionKeyKey] = nil;
    self.uid = nil;
    self.keychain[UidKey] = nil;
}

// call gettoken and set our values from returned result
- (BFTask *)getToken:(NSString *)identityId logins:(NSDictionary *)logins {
    
    // make sure we've authenticated
    if (![self isAuthenticated]) {
        return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                         code:DeveloperAuthenticationClientLoginError
                                                     userInfo:nil]];
    }
    
    return [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        NSURL *request = [NSURL URLWithString:[self buildGetTokenRequestUrl:identityId logins:logins]];
        NSData *rawResponse = [NSData dataWithContentsOfURL:request];
        if (!rawResponse) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientLoginError
                                                         userInfo:nil]];
        }
        
        NSString *response = [[NSString alloc] initWithData:rawResponse encoding:NSUTF8StringEncoding];
        NSData *body = [Crypto decrypt:response key:self.key];
        if (!body) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientDecryptError
                                                         userInfo:nil]];
        }
        
        NSString *json = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        NSLog(@"json: %@", json);
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:body options:kNilOptions error:nil];
        
        DeveloperAuthenticationResponse *authResponse = [DeveloperAuthenticationResponse new];
    
        authResponse.token = [jsonDict objectForKey:@"token"];
        authResponse.identityId = [jsonDict objectForKey:@"identityId"];
        authResponse.identityPoolId = [jsonDict objectForKey:@"identityPoolId"];
        if (!(authResponse.token || authResponse.identityId || authResponse.identityPoolId)) {
            return [BFTask taskWithError:[NSError errorWithDomain:DeveloperAuthenticationClientDomain
                                                             code:DeveloperAuthenticationClientUnknownError
                                                         userInfo:nil]];
        }
        
        return [BFTask taskWithResult:authResponse];
    }];
}

- (NSString *)buildLoginRequestUrl:(NSString *)username password:(NSString *)password {
    
    NSDate   *currentTime = [NSDate date];
    NSString *timestamp = [currentTime aws_stringValue:AWSDateISO8601DateFormat1];
    NSData   *signature = [Crypto sha256HMac:[timestamp dataUsingEncoding:NSASCIIStringEncoding] withKey:[self computeDecryptionKey:username password:password]];
    NSString *rawSig    = [[NSString alloc] initWithData:signature encoding:NSASCIIStringEncoding];
    NSString *hexSign   = [Crypto hexEncode:rawSig];
    
    return [NSString stringWithFormat:LoginURI, self.endpoint, self.uid, username, timestamp, hexSign];
}

- (NSString *)buildGetTokenRequestUrl:(NSString *)identityId logins:(NSDictionary *)logins {
    NSDate   *currentTime = [NSDate date];
    NSString *timestamp = [currentTime aws_stringValue:AWSDateISO8601DateFormat1];
    NSMutableString *stringToSign = [NSMutableString stringWithString:timestamp];
    NSMutableString *providerParams = [NSMutableString stringWithString:@""];
    int loginCount = 1;
    for (NSString *provider in [logins allKeys]) {
        [stringToSign appendFormat:@"%@%@", provider, [logins objectForKey:provider]];
        [providerParams appendFormat:@"&provider%d=%@&token%d=%@",loginCount,provider,loginCount, [logins objectForKey:provider]];
        loginCount++;
    }
    if (identityId) {
        [stringToSign appendString:identityId];
        [providerParams appendFormat:@"&identityId=%@", [identityId aws_stringWithURLEncoding]];
    }
    NSData   *signature = [Crypto sha256HMac:[stringToSign dataUsingEncoding:NSUTF8StringEncoding] withKey:self.key];
    NSString *rawSig    = [[NSString alloc] initWithData:signature encoding:NSASCIIStringEncoding];
    NSString *hexSign   = [Crypto hexEncode:rawSig];
    
    return [NSString stringWithFormat:GetTokenURI, self.endpoint, self.uid, timestamp, providerParams, hexSign];
}

- (NSString *)computeDecryptionKey:(NSString *)username password:(NSString *)password {
    NSURL *URL = [NSURL URLWithString:self.endpoint];
    NSString *hostname = URL.host;
    

    NSString *salt       = [NSString stringWithFormat:@"%@%@%@", username, self.appname, hostname];
    NSData   *hashedSalt = [Crypto sha256HMac:[salt dataUsingEncoding:NSUTF8StringEncoding] withKey:password];
    NSString *rawSaltStr = [[NSString alloc] initWithData:hashedSalt encoding:NSASCIIStringEncoding];
    
    return [Crypto hexEncode:rawSaltStr];
}


@end
