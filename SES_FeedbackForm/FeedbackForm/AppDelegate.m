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
#import "ViewController.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    // Override point for customization after application launch.
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];

    UINavigationController *container = [UINavigationController new];
    [container pushViewController:self.viewController animated:NO];
    self.window.rootViewController = container;
    [container release];

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

@end
