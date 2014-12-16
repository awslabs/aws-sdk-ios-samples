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
#import "S3UploaderViewController.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation AppDelegate

@synthesize window = _window;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UINavigationController *container = [UINavigationController new];
    container.navigationBar.translucent = NO;
    
    S3UploaderViewController *s3Uploader = [S3UploaderViewController new];
    [container pushViewController:s3Uploader animated:NO];
    [s3Uploader release];

    _window.rootViewController = container;
    [container release];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif
    
    [AmazonErrorHandler shouldNotThrowExceptions];
    
    [_window makeKeyAndVisible];
    
    return YES;
}

-(void)dealloc
{
    [_window release];
    
    [super dealloc];
}

@end
