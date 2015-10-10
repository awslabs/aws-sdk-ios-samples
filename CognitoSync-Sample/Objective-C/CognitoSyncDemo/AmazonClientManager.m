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

#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "AmazonClientManager.h"
#import "Constants.h"
#import "DeveloperAuthenticatedIdentityProvider.h"
#import "DeveloperAuthenticationClient.h"

#define FB_PROVIDER             @"Facebook"
#define GOOGLE_PROVIDER         @"Google"
#define AMZN_PROVIDER           @"Amazon"
#define TWITTER_PROVIDER        @"Twitter"
#define DIGITS_PROVIDER         @"Digits"
#define BYOI_PROVIDER           @"DeveloperAuth"

@interface AmazonClientManager()

@property (nonatomic, strong) AWSCognitoCredentialsProvider *credentialsProvider;
@property (atomic, copy) AWSContinuationBlock completionHandler;
@property (nonatomic, strong) UICKeyChainStore *keychain;
@property (nonatomic, strong) DeveloperAuthenticationClient *devAuthClient;

#if GOOGLE_LOGIN
@property (strong, nonatomic) GTMOAuth2Authentication *googleAuth;
#endif

#if FB_LOGIN
@property (strong, nonatomic) FBSDKLoginManager *facebookLogin;
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
        sharedInstance.devAuthClient = [[DeveloperAuthenticationClient alloc] initWithAppname:DeveloperAuthAppName endpoint:DeveloperAuthEndpoint];
    });
    return sharedInstance;
}

- (BOOL)isConfigured {
    return !([CognitoIdentityPoolId isEqualToString:@"YourCognitoIdentityPoolId"] || CognitoRegionType == AWSRegionUnknown);
}

- (BOOL)isLoggedInWithFacebook {
    BOOL loggedIn = NO;
#if FB_LOGIN
    loggedIn = [FBSDKAccessToken currentAccessToken] != nil;
#endif
    return self.keychain[FB_PROVIDER] != nil && loggedIn;
}

- (BOOL)isLoggedInWithGoogle {
    BOOL loggedIn = NO;
#if GOOGLE_LOGIN
    loggedIn = self.googleAuth != nil;
#endif
    return self.keychain[GOOGLE_PROVIDER] != nil && loggedIn;
}

- (BOOL)isLoggedInWithAmazon {
    return self.keychain[AMZN_PROVIDER] != nil;
}

- (BOOL)isLoggedInWithBYOI {
    return self.keychain[BYOI_PROVIDER] != nil && [self.devAuthClient isAuthenticated];
}

- (BOOL)isLoggedInWithTwitter {
    BOOL loggedIn = NO;
#if TWITTER_LOGIN
    loggedIn = [Twitter sharedInstance].session != nil;
#endif
    return self.keychain[TWITTER_PROVIDER] != nil && loggedIn;
}

- (BOOL)isLoggedInWithDigits {
    BOOL loggedIn = NO;
#if TWITTER_LOGIN
    loggedIn = [Digits sharedInstance].session != nil;
#endif
    return self.keychain[DIGITS_PROVIDER] != nil && loggedIn;
}


- (BOOL)isLoggedIn
{
    return ( [self isLoggedInWithFacebook] || [self isLoggedInWithGoogle] || [self isLoggedInWithAmazon] ||
            [self isLoggedInWithBYOI] || [self isLoggedInWithTwitter] || [self isLoggedInWithDigits]);
}

- (AWSTask *)initializeClients:(NSDictionary *)logins {
    NSLog(@"initializing clients...");
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

    id<AWSCognitoIdentityProvider> identityProvider = [[DeveloperAuthenticatedIdentityProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                              identityId:nil
                                                                                                          identityPoolId:CognitoIdentityPoolId
                                                                                                                  logins:logins
                                                                                                            providerName:DeveloperAuthProviderName
                                                                                                              authClient:self.devAuthClient];

    self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                        identityProvider:identityProvider
                                                                           unauthRoleArn:nil
                                                                             authRoleArn:nil];

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoRegionType
                                                                         credentialsProvider:self.credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    return [self.credentialsProvider getIdentityId];
}

- (void)wipeAll
{
    self.credentialsProvider.logins = nil;

    [[AWSCognito defaultCognito] wipe];
    [self.credentialsProvider clearKeychain];
}

- (void)logoutWithCompletionHandler:(AWSContinuationBlock)completionHandler
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
#if TWITTER_LOGIN
    if ([self isLoggedInWithTwitter]) {
        [self TwitterLogout];
    }
    if ([self isLoggedInWithDigits]) {
        [self DigitsLogout];
    }
#endif
    [self.devAuthClient logout];

    [self wipeAll];
    [[AWSTask taskWithResult:nil] continueWithBlock:completionHandler];
}


- (void)loginFromView:(UIView *)theView withCompletionHandler:(AWSContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;
    [[AmazonClientManager loginSheet] showInView:theView];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
#if FB_LOGIN
    // attempt to extract a FB token from the url
    if ([[FBSDKApplicationDelegate sharedInstance] application:application
                                                       openURL:url
                                             sourceApplication:sourceApplication
                                                    annotation:annotation]) {
        return YES;
    }
#endif
#if AMZN_LOGIN
    // Handle Login with Amazon redirect
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

- (void)resumeSessionWithCompletionHandler:(AWSContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;

    if (self.keychain[BYOI_PROVIDER]) {
        [self reloadBYOISession];
    }
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
#if TWITTER_LOGIN
    if (self.keychain[TWITTER_PROVIDER]) {
        [self TwitterLogin];
    }
    if (self.keychain[DIGITS_PROVIDER]) {
        [self DigitsLogin];
    }
#endif
    if (self.credentialsProvider == nil) {
        [self completeLogin:nil];
    }
}

-(void)completeLogin:(NSDictionary *)logins {
    AWSTask *task;
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

    [[task continueWithBlock:^id(AWSTask *task) {
        if(!task.error){
            //if we have a new device token register it
            __block NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            __block NSData *currentDeviceToken = [userDefaults objectForKey:DeviceTokenKey];
            __block NSString *currentDeviceTokenString = (currentDeviceToken == nil)? nil : [currentDeviceToken base64EncodedStringWithOptions:0];
            if(currentDeviceToken != nil && ![currentDeviceTokenString isEqualToString:[userDefaults stringForKey:CognitoDeviceTokenKey]]){
                [[[AWSCognito defaultCognito] registerDevice:currentDeviceToken] continueWithBlock:^id(AWSTask *task) {
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
                              otherButtonTitles:FB_PROVIDER, GOOGLE_PROVIDER, AMZN_PROVIDER, TWITTER_PROVIDER, DIGITS_PROVIDER, BYOI_PROVIDER, nil];
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
        [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
        return;
    }
    else if ([buttonTitle isEqualToString:BYOI_PROVIDER]) {
        [self BYOILogin];
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
#if TWITTER_LOGIN
    else if ([buttonTitle isEqualToString:TWITTER_PROVIDER]) {
        [self TwitterLogin];
    }
    else if ([buttonTitle isEqualToString:DIGITS_PROVIDER]) {
        [self DigitsLogin];
    }
#endif
    else {
        [[AmazonClientManager errorAlert:@"Provider not implemented"] show];
        [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}

#pragma mark - BYOI
- (void)reloadBYOISession {
    [self completeLogin:@{DeveloperAuthProviderName: self.keychain[BYOI_PROVIDER]}];
}

- (void)BYOILogin
{
    UIAlertView *loginView = [[UIAlertView alloc] initWithTitle:@"Enter Credentials" message:nil delegate:self cancelButtonTitle:@"Login" otherButtonTitles:nil];
    loginView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [loginView show];
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
        [[self.devAuthClient login:username password:password] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
            if (task.cancelled) {
                [[AmazonClientManager errorAlert:@"Login canceled."] show];
            }
            else if (task.error) {
                [[AmazonClientManager errorAlert:@"Login failed. Check your username and password."] show];
                [[AWSTask taskWithError:task.error] continueWithBlock:self.completionHandler];
            }
            else {
                self.keychain[BYOI_PROVIDER] = username;
                [self completeLogin:@{DeveloperAuthProviderName: username}];
            }
            return nil;
        }];
    }
    else {
        [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}

#if FB_LOGIN
#pragma mark - Facebook

- (void)reloadFBSession
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self CompleteFBLogin];
    }
}


- (void)CompleteFBLogin
{
    self.keychain[FB_PROVIDER] = @"YES";
    [self completeLogin:@{@"graph.facebook.com": [FBSDKAccessToken currentAccessToken].tokenString}];

}

- (void)FBLogin
{
    if ([FBSDKAccessToken currentAccessToken]) {
        [self CompleteFBLogin];
        return;
    }

    if (!self.facebookLogin)
        self.facebookLogin = [FBSDKLoginManager new];
    
    [self.facebookLogin logInWithReadPermissions:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.localizedDescription]] show];
        } else if (result.isCancelled) {
            // Login canceled, do nothing
        } else {
            [self CompleteFBLogin];
        }
    }];
}

- (void)FBLogout
{
    if (!self.facebookLogin)
        self.facebookLogin = [FBSDKLoginManager new];
    
    [self.facebookLogin logOut];
    self.keychain[FB_PROVIDER] = nil;
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
}

- (void)requestDidSucceed:(APIResult*) apiResult {
    if (apiResult.api == kAPIAuthorizeUser) {
        [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"] withOverrideParams:nil delegate:self];
    }
    else if (apiResult.api == kAPIGetAccessToken) {
        NSString *token = (NSString *)apiResult.result;
        NSLog(@"%@", token);

        self.keychain[AMZN_PROVIDER] = @"YES";
        [self completeLogin:@{@"www.amazon.com": token}];
    }
}

- (void)requestDidFail:(APIError*) errorResponse {
    [[AmazonClientManager errorAlert:[NSString stringWithFormat:@"Error logging in with Amazon: %@", errorResponse.error.message]] show];

    [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
}

#endif

#if TWITTER_LOGIN

#pragma mark - Twitter/Digits
- (void)TwitterLogin
{
    [[Twitter sharedInstance] logInWithCompletion:^
     (TWTRSession *session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session userName]);
             [self CompleteTwitterLogin];
         } else {
             NSLog(@"error: %@", [error localizedDescription]);
         }
     }];
}

- (void)CompleteTwitterLogin
{
    self.keychain[TWITTER_PROVIDER] = @"YES";
    [self completeLogin:@{@"api.twitter.com":[self loginForTwitterSession:[Twitter sharedInstance].session]}];
}

- (void)TwitterLogout
{
    [[Twitter sharedInstance] logOut];
    self.keychain[TWITTER_PROVIDER] = nil;
}

- (void)DigitsLogin
{
    [[Digits sharedInstance] authenticateWithCompletion:^
     (DGTSession* session, NSError *error) {
         if (session) {
             NSLog(@"signed in as %@", [session phoneNumber]);
             [self CompleteDigitsLogin];
         }
     }];
}

- (void)CompleteDigitsLogin
{
    self.keychain[DIGITS_PROVIDER] = @"YES";
    [self completeLogin:@{@"www.digits.com":[self loginForTwitterSession:[Digits sharedInstance].session]}];
}

- (void)DigitsLogout
{
    [[Digits sharedInstance] logOut];
    self.keychain[DIGITS_PROVIDER] = nil;
}

- (NSString *)loginForTwitterSession:(id<TWTRAuthSession>) session {
    return [NSString stringWithFormat:@"%@;%@", session.authToken, session.authTokenSecret];
}

#endif
     
#if GOOGLE_LOGIN
#pragma mark - Google
- (GPPSignIn *)getGPlusLogin
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.delegate = self;
    signIn.clientID = GoogleClientID;
    signIn.scopes = [NSArray arrayWithObjects:GoogleClientScope, GoogleOIDCScope, nil];
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
    self.googleAuth = nil;
    self.keychain[GOOGLE_PROVIDER] = nil;
}

- (void)reloadGSession
{
    GPPSignIn *signIn = [self getGPlusLogin];
    [signIn trySilentAuthentication];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (self.googleAuth == nil) {
        self.googleAuth = auth;

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
    NSString *idToken = [self.googleAuth.parameters objectForKey:@"id_token"];

    self.keychain[GOOGLE_PROVIDER] = @"YES";
    [self completeLogin:@{@"accounts.google.com": idToken}];
}
#endif

@end
