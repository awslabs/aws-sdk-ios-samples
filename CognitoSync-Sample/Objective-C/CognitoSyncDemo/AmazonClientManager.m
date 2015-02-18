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

#import "AWSCore.h"
#import "AmazonClientManager.h"
#import "AWSCredentialsProvider.h"
#import "AWSLogging.h"
#import "Constants.h"
#import "BFTask.h"
#import "UICKeyChainStore.h"
#import "Cognito.h"
#import "DeveloperAuthenticatedIdentityProvider.h"
#import "DeveloperAuthenticationClient.h"
#import "Constants.h"

#define FB_PROVIDER             @"Facebook"
#define GOOGLE_PROVIDER         @"Google"
#define AMZN_PROVIDER           @"Amazon"
#define BYOI_PROVIDER           @"DeveloperAuth"

@interface AmazonClientManager()

@property (nonatomic, strong) AWSCognitoCredentialsProvider *credentialsProvider;
@property (atomic, copy) BFContinuationBlock completionHandler;
@property (nonatomic, strong) UICKeyChainStore *keychain;
@property (nonatomic, strong) DeveloperAuthenticationClient *devAuthClient;

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
#if BYOI_LOGIN
        sharedInstance.devAuthClient = [[DeveloperAuthenticationClient alloc] initWithAppname:AppName endpoint:Endpoint];
#endif
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

- (BOOL)isLoggedInWithBYOI {
    return self.keychain[BYOI_PROVIDER] != nil && [self.devAuthClient isAuthenticated];
}


- (BOOL)isLoggedIn
{
    return ( [self isLoggedInWithFacebook] || [self isLoggedInWithGoogle] || [self isLoggedInWithAmazon] || [self isLoggedInWithBYOI] );
}

- (BFTask *)initializeClients:(NSDictionary *)logins {
    NSLog(@"initializing clients...");
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

#if BYOI_LOGIN
    id<AWSCognitoIdentityProvider> identityProvider = [[DeveloperAuthenticatedIdentityProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                              identityId:nil
                                                                                                                         identityPoolId:CognitoIdentityPoolId
                                                                                                                  logins:logins
                                                                                                            providerName:ProviderName
                                                                                                              authClient:self.devAuthClient];
#else
    id<AWSCognitoIdentityProvider> identityProvider = [[AWSEnhancedCognitoIdentityProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                       identityId:nil
                                                                                                   identityPoolId:CognitoIdentityPoolId
                                                                                                           logins:logins];
#endif


    self.credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:CognitoRegionType
                                                                       identityProvider:identityProvider
                                                                          unauthRoleArn:nil
                                                                            authRoleArn:nil];

    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:CognitoRegionType
                                                                          credentialsProvider:self.credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    return [self.credentialsProvider getIdentityId];
}

- (void)wipeAll
{
    self.credentialsProvider.logins = nil;

    [[AWSCognito defaultCognito] wipe];
    [self.credentialsProvider clearKeychain];
}

- (void)logoutWithCompletionHandler:(BFContinuationBlock)completionHandler
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
    [self.devAuthClient logout];

    [self wipeAll];
    [[BFTask taskWithResult:nil] continueWithBlock:completionHandler];
}


- (void)loginFromView:(UIView *)theView withCompletionHandler:(BFContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;
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

- (void)resumeSessionWithCompletionHandler:(BFContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;

#if BYOI_LOGIN
    if (self.keychain[BYOI_PROVIDER]) {
        [self reloadBYOISession];
    }
#endif
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

    if (self.credentialsProvider == nil) {
        [self completeLogin:nil];
    }

    self.completionHandler = nil;
}

-(void)completeLogin:(NSDictionary *)logins {
    BFTask *task;
    if (self.credentialsProvider == nil) {
        task = [self initializeClients:logins];
    }
    else {
        NSMutableDictionary *merge = [NSMutableDictionary dictionaryWithDictionary:self.credentialsProvider.logins];
        [merge addEntriesFromDictionary:logins];
        self.credentialsProvider.logins = merge;
        // Force a refresh of credentials to see if we need to merge
        task = [self.credentialsProvider refresh];
    }

    [[task continueWithBlock:^id(BFTask *task) {
        if(!task.error){
            //if we have a new device token register it
            __block NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            __block NSData *currentDeviceToken = [userDefaults objectForKey:DeviceTokenKey];
            __block NSString *currentDeviceTokenString = (currentDeviceToken == nil)? nil : [currentDeviceToken base64EncodedStringWithOptions:0];
            if(currentDeviceToken != nil && ![currentDeviceTokenString isEqualToString:[userDefaults stringForKey:CognitoDeviceTokenKey]]){
                [[[AWSCognito defaultCognito] registerDevice:currentDeviceToken] continueWithBlock:^id(BFTask *task) {
                    if(!task.error){
                        [userDefaults setObject:currentDeviceTokenString forKey:CognitoDeviceTokenKey];
                        [userDefaults synchronize];
                    }
                    return nil;
                }];
            }
        }
        return task;
    }] continueWithBlock:self.completionHandler];
}

#pragma mark - UI Helpers

+ (UIActionSheet *)loginSheet
{
    return [[UIActionSheet alloc] initWithTitle:@"Choose Identity Provider"
                                       delegate:[AmazonClientManager sharedInstance]
                              cancelButtonTitle:@"Cancel"
                         destructiveButtonTitle:nil
                              otherButtonTitles:FB_PROVIDER, GOOGLE_PROVIDER, AMZN_PROVIDER, BYOI_PROVIDER, nil];
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
        [[BFTask taskWithResult:nil] continueWithBlock:self.completionHandler];
        return;
    }
#if BYOI_LOGIN
    else if ([buttonTitle isEqualToString:BYOI_PROVIDER]) {
        [self BYOILogin];
    }
#endif
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
        [[BFTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}

#if BYOI_LOGIN
#pragma mark - BYOI
- (void)reloadBYOISession {
    [self completeLogin:@{ProviderName: self.keychain[BYOI_PROVIDER]}];
}

- (void)BYOILogin
{
    UIAlertView *login = [[UIAlertView alloc] initWithTitle:@"Enter Credentials" message:nil delegate:self cancelButtonTitle:@"Login" otherButtonTitles:nil];
    login.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [login show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *username = [alertView textFieldAtIndex:0].text;
    NSString *password = [alertView textFieldAtIndex:1].text;
    if ([username length] == 0 || [password length] == 0) {
        username = nil;
        password = nil;
    }

    if (username && password) {
        [[self.devAuthClient login:username password:password] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
            if (task.cancelled) {
                [[AmazonClientManager errorAlert:@"Login canceled."] show];
            }
            else if (task.error) {
                [[AmazonClientManager errorAlert:@"Login failed. Check your username and password."] show];
                [[BFTask taskWithError:task.error] continueWithBlock:self.completionHandler];
            }
            else {
                self.keychain[BYOI_PROVIDER] = username;
                [self.keychain synchronize];
                [self completeLogin:@{ProviderName: username}];
            }
            return nil;
        }];
    }
    else {
        [[BFTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}
#endif

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

    [[BFTask taskWithResult:nil] continueWithBlock:self.completionHandler];
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
