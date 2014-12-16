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
#import "AWSiOSDemoViewController.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UINavigationController *container = [UINavigationController new];
    _viewController = [[AWSiOSDemoViewController alloc] initWithNibName:@"AWSiOSDemoViewController" bundle:nil];
    [container pushViewController:self.viewController animated:NO];

    container.navigationBar.translucent = NO;
    self.window.rootViewController = container;
    [container release];

    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif
    
    [AmazonErrorHandler shouldNotThrowExceptions];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)dealloc
{
    [_viewController release];
    [_window release];
    [super dealloc];
}

@end