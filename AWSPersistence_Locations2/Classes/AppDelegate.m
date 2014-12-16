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

#import <AWSPersistence/AWSPersistenceDynamoDBIncrementalStore.h>

#import <AWSRuntime/AWSRuntime.h>

#import "AppDelegate.h"
#import "RootViewController.h"
#import "AmazonClientManager.h"
#import "CoreDataManager.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Logging Control - Do NOT use logging for non-development builds.
#ifdef DEBUG
    [AmazonLogger verboseLogging];
#else
    [AmazonLogger turnLoggingOff];
#endif
    
    [AmazonErrorHandler shouldNotThrowExceptions];

    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _managedObjectModel = nil;
    _managedObjectContext = nil;
    _persistentStoreCoordinator = nil;
		
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
        NSLog(@"Unable to create context");
        return NO;
	}
    [CoreDataManager sharedInstance].managedObjectContext = context;
    
	// Configure and show the window
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	_navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    self.window.rootViewController = self.navigationController;
	[self.window makeKeyAndVisible];    
    
    return YES;
}

/**
 * applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}

#pragma mark -
#pragma mark Core Data stack

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{	
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        
        //Undo Support
        NSUndoManager *undoManager = [NSUndoManager new];
        _managedObjectContext.undoManager = undoManager;
        
        _managedObjectContext.persistentStoreCoordinator = coordinator;
        _managedObjectContext.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType];
    }
    
    return _managedObjectContext;
}


/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel
{	
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}


/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{	
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
	
    NSError *error;
    
    // Registers the AWSNSIncrementalStore
    [NSPersistentStoreCoordinator registerStoreClass:[AWSPersistenceDynamoDBIncrementalStore class] forStoreType:AWSPersistenceDynamoDBIncrementalStoreType];
    
    // Instantiates PersistentStoreCoordinator
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Creates options for the AWSNSIncrementalStore
    NSDictionary *hashKeys = [NSDictionary dictionaryWithObjectsAndKeys:
                              LOCATIONS_KEY, @"Location", 
                              CHECKINS_KEY, @"Checkin", nil];
    NSDictionary *versions = [NSDictionary dictionaryWithObjectsAndKeys:
                              LOCATIONS_VERSIONS, @"Location", 
                              CHECKINS_VERSIONS, @"Checkin", nil];
    NSDictionary *tableMapper = [NSDictionary dictionaryWithObjectsAndKeys:
                                 LOCATIONS_TABLE, @"Location",
                                 CHECKINS_TABLE, @"Checkin", nil];

    AmazonClientManager *provider = [AmazonClientManager new];
    AmazonDynamoDBClient *ddb = [[AmazonDynamoDBClient alloc] initWithCredentialsProvider:provider];
    ddb.endpoint = [AmazonEndpoints ddbEndpoint:US_WEST_2];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             hashKeys, AWSPersistenceDynamoDBHashKey, 
                             versions, AWSPersistenceDynamoDBVersionKey,
                             ddb, AWSPersistenceDynamoDBClient,
                             tableMapper, AWSPersistenceDynamoDBTableMapper, nil];
    
    // Adds the AWSNSIncrementalStore to the PersistentStoreCoordinator
    if(![_persistentStoreCoordinator addPersistentStoreWithType:AWSPersistenceDynamoDBIncrementalStoreType 
                                                 configuration:nil 
                                                           URL:nil 
                                                       options:options 
                                                         error:&error])
    {
        // Handle the error.
        NSLog(@"Unable to create store. Error: %@", error);
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark -

@end
