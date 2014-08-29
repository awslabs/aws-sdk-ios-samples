/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "AWSCore.h"
#import "AmazonClientManager.h"
#import "AWSCredentialsProvider.h"
#import "AWSLogging.h"
#import "Constants.h"
#import "BFTask.h"
#import "UICKeyChainStore.h"
#import "Cognito.h"

#define FB_PROVIDER             @"Facebook"
#define GOOGLE_PROVIDER         @"Google"
#define AMZN_PROVIDER           @"Amazon"

@interface AmazonClientManager()

@property (nonatomic, strong) AWSCognitoCredentialsProvider *provider;
@property (atomic, copy) LoginHandler callback;
@property (nonatomic, strong) UICKeyChainStore *keychain;

#if FB_LOGIN
@property (strong, nonatomic) FBSession *session;
#endif

#if GOOGLE_LOGIN
@property (strong, nonatomic) GTMOAuth2Authentication *auth;
#endif

@end



@implementation AmazonClientManager

+ (AmazonClientManager *)sharedInstance
{
    static AmazonClientManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [AmazonClientManager new];
        sharedInstance.keychain = [UICKeyChainStore keyChainStoreWithService:[NSString stringWithFormat:@"%@.%@", [NSBundle mainBundle].bundleIdentifier, [AmazonClientManager class]]];
    });
    return sharedInstance;
}

- (BOOL)isLoggedInWithFacebook {
    BOOL loggedIn = NO;
#if FB_LOGIN
    loggedIn = self.session != nil;
#endif
    return self.keychain[FB_PROVIDER] != nil && loggedIn;
}

- (BOOL)isLoggedInWithGoogle {
    BOOL loggedIn = NO;
#if GOOGLE_LOGIN
    loggedIn = self.auth != nil;
#endif
    return self.keychain[GOOGLE_PROVIDER] != nil && loggedIn;
}

- (BOOL)isLoggedInWithAmazon {
    return self.keychain[AMZN_PROVIDER] != nil;
}

- (BOOL)isLoggedIn
{
    return ( [self isLoggedInWithFacebook] || [self isLoggedInWithGoogle] || [self isLoggedInWithAmazon] );
}

- (BFTask *)initializeClients:(NSDictionary *)logins {
    NSLog(@"initializing clients...");
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    self.provider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                   accountId:AWSAccountID
                                                              identityPoolId:CognitoPoolID
                                                               unauthRoleArn:CognitoRoleUnauth
                                                                 authRoleArn:CognitoRoleAuth];

    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:self.provider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    return [self.provider getIdentityId];
}

- (void)wipeAll
{
    [[AWSCognito defaultCognito] wipe];
    [self.provider clearKeychain];
}

- (void)logoutWithCompletionHandler:(LoginHandler)completionHandler
{
#if FB_LOGIN
    if ([self isLoggedInWithFacebook]) {
        [self FBLogout];
    }
#endif
#if AMZN_LOGIN
    if ([self isLoggedInWithAmazon]) {
        [self AMZNLogout];
    }
#endif
#if GOOGLE_LOGIN
    if ([self isLoggedInWithGoogle]) {
        [self GoogleLogout];
    }
#endif
    
    [self wipeAll];
    completionHandler(nil);
}


- (void)loginFromView:(UIView *)theView withCompletionHandler:(LoginHandler)completionHandler
{
    self.callback = completionHandler;
    [[AmazonClientManager loginSheet] showInView:theView];
}


- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
#if FB_LOGIN
    // attempt to extract a FB token from the url
    if ([self.session handleOpenURL:url]) {
        return YES;
    }
#endif
#if AMZN_LOGIN
    if ([AIMobileLib handleOpenURL:url sourceApplication:sourceApplication]) {
        return YES;
    }
#endif
#if GOOGLE_LOGIN
    // Handle Google+ sign-in button URL.
    if ([GPPURLHandler handleURL:url
               sourceApplication:sourceApplication
                      annotation:annotation]) {
        return YES;
    }
#endif
    return NO;
}

- (void)resumeSessionWithCompletionHandler:(LoginHandler)completionHandler
{
    self.callback = completionHandler;
    
#if FB_LOGIN
    if (self.keychain[FB_PROVIDER]) {
        [self reloadFBSession];
    }
#endif
#if AMZN_LOGIN
    if (self.keychain[AMZN_PROVIDER]) {
        [self AMZNLogin];
    }
#endif
#if GOOGLE_LOGIN
    if (self.keychain[GOOGLE_PROVIDER]) {
        [self reloadGSession];
    }
#endif
    
    if (self.provider == nil) {
        [self completeLogin:nil];
    }
}

-(void)completeLogin:(NSDictionary *)logins {
    BFTask *task;
    if (self.provider == nil) {
        task = [self initializeClients:logins];
    }
    else {
        NSMutableDictionary *merge = [NSMutableDictionary dictionaryWithDictionary:self.provider.logins];
        [merge addEntriesFromDictionary:logins];
        self.provider.logins = merge;
        // Force a refresh of credentials to see if we need to merge
        task = [self.provider refresh];
    }
    [task continueWithBlock:^id(BFTask *task) {
        self.callback(task.error);
        self.callback = nil;
        return nil;
    }];
}

#pragma mark - UI Helpers

+ (UIActionSheet *)loginSheet
{
    return [[UIActionSheet alloc] initWithTitle:@"Choose Identity Provider"
                                       delegate:[AmazonClientManager sharedInstance]
                              cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:nil
                              otherButtonTitles:FB_PROVIDER, GOOGLE_PROVIDER, AMZN_PROVIDER, nil];
}

+ (UIAlertView *)errorAlert:(NSString *)message
{
    return [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        return;
    }
#if FB_LOGIN
    else if ([buttonTitle isEqualToString:FB_PROVIDER]) {
        [self FBLogin];
    }
#endif
#if AMZN_LOGIN
    else if ([buttonTitle isEqualToString:AMZN_PROVIDER]) {
        [self AMZNLogin];
    }
#endif
#if GOOGLE_LOGIN
    else if ([buttonTitle isEqualToString:GOOGLE_PROVIDER]) {
        [self GoogleLogin];
    }
#endif
    else {
        [[AmazonClientManager errorAlert:@"Provider not implemented"] show];
    }
}

#if FB_LOGIN
#pragma mark - Facebook

- (void)reloadFBSession
{
    if (!self.session.isOpen) {
        // create a fresh session object
        
        self.session = [FBSession new];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                if (error == nil) {
                    [self CompleteFBLogin];
                }
                else {
                    [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
                }
                
            }];
        }
    }
}


- (void)CompleteFBLogin
{
    if (![self.session isOpen])
        return;
    
    self.keychain[FB_PROVIDER] = @"YES";
    [self.keychain synchronize];
    
    // set active session
    FBSession.activeSession = self.session;
    [self completeLogin:@{@"graph.facebook.com": self.session.accessTokenData.accessToken}];

}

- (void)FBLogin
{
    // session already open, exit
    if (self.session.isOpen) {
        [self CompleteFBLogin];
        return;
    }
    
    if (self.session == nil || self.session.state != FBSessionStateCreated) {
        // Create a new, logged out session.
        self.session = [FBSession new];
    }
    
    [self.session openWithCompletionHandler:^(FBSession *session,
                                              FBSessionState status,
                                              NSError *error) {
        if (error != nil) {
            [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
        }
        else {
            [self CompleteFBLogin];
        }
    }];
    
}

- (void)FBLogout
{
    [self.session closeAndClearTokenInformation];
    self.session = nil;
    self.keychain[FB_PROVIDER] = nil;
    [self.keychain synchronize];
}
#endif

#if AMZN_LOGIN
#pragma mark - Login With Amazon


- (void)AMZNLogin
{
    [AIMobileLib authorizeUserForScopes:[NSArray arrayWithObject:@"profile"] delegate:self];
}

- (void)AMZNLogout
{
    [AIMobileLib clearAuthorizationState:self];
    self.keychain[AMZN_PROVIDER] = nil;
    [self.keychain synchronize];
}

- (void)requestDidSucceed:(APIResult*) apiResult {
    if (apiResult.api == kAPIAuthorizeUser) {
        [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"] withOverrideParams:nil delegate:self];
    }
    else if (apiResult.api == kAPIGetAccessToken) {
        NSString *token = (NSString *)apiResult.result;
        NSLog(@"%@", token);
        
        self.keychain[AMZN_PROVIDER] = @"YES";
        [self.keychain synchronize];
        [self completeLogin:@{@"www.amazon.com": token}];
    }
}

- (void)requestDidFail:(APIError*) errorResponse {
    [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with Amazon: %@", errorResponse.error.message]] show];
    
    if (self.callback) {
        self.callback(nil);
        self.callback = nil;
    }
}

#endif

#if GOOGLE_LOGIN
#pragma mark - Google
- (GPPSignIn *)getGPlusLogin
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.delegate = self;
    signIn.clientID = GOOGLE_CLIENT_ID;
    signIn.scopes = [NSArray arrayWithObjects:GOOGLE_CLIENT_SCOPE, GOOGLE_OPENID_SCOPE, nil];
    return signIn;
}

- (void)GoogleLogin
{
    GPPSignIn *signIn = [self getGPlusLogin];
    [signIn authenticate];
}

- (void)GoogleLogout
{
    GPPSignIn *signIn = [self getGPlusLogin];
    [signIn disconnect];
    self.auth = nil;
    self.keychain[GOOGLE_PROVIDER] = nil;
    [self.keychain synchronize];
}

- (void)reloadGSession
{
    GPPSignIn *signIn = [self getGPlusLogin];
    [signIn trySilentAuthentication];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (self.auth == nil) {
        self.auth = auth;
        
        if (error != nil) {
            [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with Google: %@", error.description]] show];
        }
        else {
            [self CompleteGLogin];
        }
    }
}

-(void)CompleteGLogin
{
    NSString *idToken = [self.auth.parameters objectForKey:@"id_token"];
    
    self.keychain[GOOGLE_PROVIDER] = @"YES";
    [self.keychain synchronize];
    [self completeLogin:@{@"accounts.google.com": idToken}];
}
#endif

@end
