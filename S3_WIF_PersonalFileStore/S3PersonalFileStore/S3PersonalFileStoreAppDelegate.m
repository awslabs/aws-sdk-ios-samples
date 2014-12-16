/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "S3PersonalFileStoreAppDelegate.h"
#import "S3PersonalFileStoreViewController.h"
#import <AWSRuntime/AWSRuntime.h>
#import "AmazonClientManager.h"


@implementation S3PersonalFileStoreAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
#if FB_LOGIN
    // attempt to extract a FB token from the url
    if ([[AmazonClientManager sharedInstance].session handleOpenURL:url]) {
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
    
#if AMZN_LOGIN
    if ([AIMobileLib handleOpenURL:url sourceApplication:sourceApplication]) {
        return YES;
    }
#endif
    
    return NO;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    window.rootViewController = viewController;
    [window makeKeyAndVisible];

    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif

    return YES;
}

-(void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}


@end
