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

#import "CoreDataManager.h"
#import "Utilities.h"

#import "Location.h"
#import "Checkin.h"

@implementation CoreDataManager

@synthesize managedObjectContext = _managedObjectContext;

static CoreDataManager *_sharedInstance = nil;

+ (CoreDataManager *)sharedInstance
{
    @synchronized([self class])
    {
        if(_sharedInstance == nil)
        {
            _sharedInstance = [CoreDataManager new];
        }
    }

    return _sharedInstance;
}

- (NSMutableArray *)listLocations
{
    @synchronized([self class])
    {
        // Fetch existing events.
        // Create a fetch request; find the Event entity and assign it to the request; add a sort descriptor; then execute the fetch.
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];

        // Execute the fetch -- create a mutable copy of the result.
        NSError *error = nil;
        NSArray *fetchedResults = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableArray *mutableFetchResults = [fetchedResults mutableCopy];

        if (mutableFetchResults == nil) {
            // Handle the error.
            NSLog(@"Problem fetching data. Error: %@", error);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"There was a problem fetching data, check application log for details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return [NSMutableArray new];
        }

        return mutableFetchResults;
    }
}

- (void)deleteLocation:(Location *)location
{
    @synchronized([self class])
    {
        [self.managedObjectContext deleteObject:location];
    }
}

- (void)deleteCheckin:(Checkin *)checkin
{
    @synchronized([self class])
    {
        [self.managedObjectContext deleteObject:checkin];
    }
}

- (Checkin *)createCheckinWithComment:(NSString *)comment
{
    @synchronized([self class])
    {
        Checkin *checkin = (Checkin *)[NSEntityDescription insertNewObjectForEntityForName:@"Checkin"
                                                                    inManagedObjectContext:self.managedObjectContext];
        checkin.checkinId = [Utilities getUUID];
        checkin.checkinTime = [NSDate date];
        checkin.comment = comment;

        return checkin;
    }
}

- (Location *)createLocationWithName:(NSString *)name
{
    @synchronized([self class])
    {
        Location *loc = (Location *)[NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                  inManagedObjectContext:self.managedObjectContext];
        loc.name = name;
        loc.locationId = [Utilities getUUID];

        return loc;
    }
}

- (BOOL)saveAllLocations:(NSArray *)locations
{
    @synchronized([self class])
    {
        BOOL saved = NO;

        for(NSManagedObject *managedObject in locations)
        {
            [self.managedObjectContext refreshObject:managedObject mergeChanges:YES];
        }

        // Commit the change.
        NSError *error;
        saved = [self.managedObjectContext save:&error];
        if (!saved)
        {
            NSLog(@"Problem saving data. Error: %@", error);
        }

        return saved;
    }
}

@end
