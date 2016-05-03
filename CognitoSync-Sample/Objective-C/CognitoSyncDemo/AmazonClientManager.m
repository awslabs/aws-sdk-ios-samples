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

@interface AmazonClientManager()

@property (nonatomic, strong) AWSCognitoCredentialsProvider *credentialsProvider;
@property (atomic, copy) AWSContinuationBlock completionHandler;
@property (nonatomic, strong) UICKeyChainStore *keychain;
@property (nonatomic, strong) DeveloperAuthenticationClient *devAuthClient;

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

- (BOOL)isLoggedInWithBYOI {
    return self.keychain[BYOI_PROVIDER] != nil && [self.devAuthClient isAuthenticated];
}

- (BOOL)isLoggedIn {
    return [self isLoggedInWithBYOI];
}

- (AWSTask *)initializeClients {
    NSLog(@"initializing clients...");
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

    DeveloperAuthenticatedIdentityProvider *identityProviderManager = [[DeveloperAuthenticatedIdentityProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                                          identityPoolId:CognitoIdentityPoolId
                                                                                                                            providerName:DeveloperAuthProviderName
                                                                                                                              authClient:self.devAuthClient
                                                                                                                 identityProviderManager:nil];

    self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                           unauthRoleArn:nil
                                                                             authRoleArn:nil
                                                                        identityProvider:identityProviderManager];

    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoRegionType
                                                                         credentialsProvider:self.credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    return [self.credentialsProvider getIdentityId];
}

- (void)wipeAll {
    [[AWSCognito defaultCognito] wipe];
    [self.credentialsProvider clearKeychain];
}

- (void)logoutWithCompletionHandler:(AWSContinuationBlock)completionHandler
{
    [self.devAuthClient logout];

    [self wipeAll];
    [[AWSTask taskWithResult:nil] continueWithBlock:completionHandler];
}


- (void)loginFromView:(UIView *)theView withCompletionHandler:(AWSContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;
    [[AmazonClientManager loginSheet] showInView:theView];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions {
    return YES;
}

- (void)resumeSessionWithCompletionHandler:(AWSContinuationBlock)completionHandler
{
    self.completionHandler = completionHandler;

    if (self.keychain[BYOI_PROVIDER]) {
        [self reloadBYOISession];
    }
    if (self.credentialsProvider == nil) {
        [self completeLogin];
    }
}

-(void)completeLogin {
    AWSTask *task;
    if (self.credentialsProvider == nil) {
        task = [self initializeClients];
    }
    else {
        // Force a refresh of credentials to see if we need to merge
        [self.credentialsProvider invalidateCachedTemporaryCredentials];
        task = [self.credentialsProvider getIdentityId];
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
                              otherButtonTitles:BYOI_PROVIDER, nil];
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
    else {
        [[AmazonClientManager errorAlert:@"Provider not implemented"] show];
        [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}

#pragma mark - BYOI
- (void)reloadBYOISession {
    [self completeLogin];
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
                [self completeLogin];
            }
            return nil;
        }];
    }
    else {
        [[AWSTask taskWithResult:nil] continueWithBlock:self.completionHandler];
    }
}

@end
