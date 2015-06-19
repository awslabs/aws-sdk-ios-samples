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

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constants.h"

#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import <AWSSNS/AWSSNS.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Configures the appearance
    [UINavigationBar appearance].barTintColor = [UIColor blackColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    // Sets up Mobile Push Notification
    UIMutableUserNotificationAction *readAction = [UIMutableUserNotificationAction new];
    readAction.identifier = @"READ_IDENTIFIER";
    readAction.title = @"Read";
    readAction.activationMode = UIUserNotificationActivationModeForeground;
    readAction.destructive = NO;
    readAction.authenticationRequired = YES;

    UIMutableUserNotificationAction *deleteAction = [UIMutableUserNotificationAction new];
    deleteAction.identifier = @"DELETE_IDENTIFIER";
    deleteAction.title = @"Delete";
    deleteAction.activationMode = UIUserNotificationActivationModeForeground;
    deleteAction.destructive = YES;
    deleteAction.authenticationRequired = YES;

    UIMutableUserNotificationAction *ignoreAction = [UIMutableUserNotificationAction new];
    ignoreAction.identifier = @"IGNORE_IDENTIFIER";
    ignoreAction.title = @"Ignore";
    ignoreAction.activationMode = UIUserNotificationActivationModeForeground;
    ignoreAction.destructive = NO;
    ignoreAction.authenticationRequired = NO;

    UIMutableUserNotificationCategory *messageCategory = [UIMutableUserNotificationCategory new];
    messageCategory.identifier = @"MESSAGE_CATEGORY";
    [messageCategory setActions:@[readAction, deleteAction] forContext:UIUserNotificationActionContextMinimal];
    [messageCategory setActions:@[readAction, deleteAction, ignoreAction] forContext:UIUserNotificationActionContextDefault];

    UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:[NSSet setWithArray:@[messageCategory]]];

    [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    // Sets up the AWS Mobile SDK for iOS
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                    identityPoolId:CognitoIdentityPoolId];
    AWSServiceConfiguration *defaultServiceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                                       credentialsProvider:credentialsProvider];

    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = defaultServiceConfiguration;

    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSLog(@"deviceTokenString: %@", deviceTokenString);
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.window.rootViewController.childViewControllers.firstObject performSelectorOnMainThread:@selector(displayDeviceInfo) withObject:nil waitUntilDone:nil];

    AWSSNS *sns = [AWSSNS defaultSNS];
    AWSSNSCreatePlatformEndpointInput *request = [AWSSNSCreatePlatformEndpointInput new];
    request.token = deviceTokenString;
    request.platformApplicationArn = SNSPlatformApplicationArn;
    [[sns createPlatformEndpoint:request] continueWithBlock:^id(AWSTask *task) {
        if (task.error != nil) {
            NSLog(@"Error: %@",task.error);
        } else {
            AWSSNSCreateEndpointResponse *createEndPointResponse = task.result;
            NSLog(@"endpointArn: %@",createEndPointResponse);
            [[NSUserDefaults standardUserDefaults] setObject:createEndPointResponse.endpointArn forKey:@"endpointArn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.window.rootViewController.childViewControllers.firstObject performSelectorOnMainThread:@selector(displayDeviceInfo) withObject:nil waitUntilDone:NO];

        }

        return nil;
    }];


}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to register with error: %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userInfo: %@",userInfo);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    AWSMobileAnalytics *mobileAnalytics = [AWSMobileAnalytics mobileAnalyticsForAppId:MobileAnalyticsAppId];
    id<AWSMobileAnalyticsEventClient> eventClient = mobileAnalytics.eventClient;
    id<AWSMobileAnalyticsEvent> pushNotificationEvent = [eventClient createEventWithEventType:@"PushNotificationEvent"];

    NSString *action = @"Undefined";
    if ([identifier isEqualToString:@"READ_IDENTIFIER"]) {
        action = @"read";
        NSLog(@"User selected 'Read'");
    } else if ([identifier isEqualToString:@"DELETE_IDENTIFIER"]) {
        action = @"Deleted";
        NSLog(@"User selected `Delete`");
    } else {
        action = @"Undefined";
    }

    [pushNotificationEvent addAttribute:action forKey:@"Action"];
    [eventClient recordEvent:pushNotificationEvent];

    [self.window.rootViewController.childViewControllers.firstObject performSelectorOnMainThread:@selector(displayUserAction:)
                                                                                      withObject:action
                                                                                   waitUntilDone:NO];
    
    completionHandler();
}

@end
