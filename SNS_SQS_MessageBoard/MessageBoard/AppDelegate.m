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


#import "AppDelegate.h"
#import "Message_BoardViewController.h"
#import "MessageBoard.h"
#import <AWSRuntime/AWSRuntime.h>
#import "Constants.h"
@implementation AppDelegate

@synthesize window = _window;



- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
    
    //Convert deviceToken to String Type
    const char* data = [deviceToken bytes];
    NSMutableString* tokenString = [NSMutableString string];
    for (int i = 0; i < [deviceToken length]; i++) {
        [tokenString appendFormat:@"%02.2hhX", data[i]];
    }
    NSLog(@"deviceToken String: %@", tokenString);
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"myDeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	NSLog(@"Failed to register with error : %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0;
    NSString *msg = [NSString stringWithFormat:@"%@", userInfo];
    NSLog(@"%@",msg);
    [[Constants universalAlertsWithTitle:@"Push Notification Received" andMessage:msg] show];
}


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Register for push notification
    application.applicationIconBadgeNumber = 0;
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    if(launchOptions!=nil){
        NSString *msg = [NSString stringWithFormat:@"%@", launchOptions];
        NSLog(@"%@",msg);
        [[Constants universalAlertsWithTitle:@"Push Notification Received" andMessage:msg] show];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    // Override point for customization after application launch.

    Message_BoardViewController *boardViewController = [Message_BoardViewController new];
    UINavigationController *navigationController = [UINavigationController new];
    
    navigationController.navigationBar.translucent = NO;
    
    [navigationController pushViewController:boardViewController animated:NO];
    [boardViewController release];

    self.window.rootViewController = navigationController;
    [navigationController release];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    [self.window makeKeyAndVisible];

    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif

    [AmazonErrorHandler shouldNotThrowExceptions];

    return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application
{
    /*
     * Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     * Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     * Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     * If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

-(void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     * Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     * Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    /*
     * Called when the application is about to terminate.
     * Save data if appropriate.
     * See also applicationDidEnterBackground:.
     */
}

-(void)dealloc
{
    [_window release];

    [super dealloc];
}

@end
