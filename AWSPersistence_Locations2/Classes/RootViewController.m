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
#import "Checkin.h"
#import "Location.h"
#import "RootViewController.h"
#import "Utilities.h"
#import "CheckinsViewController.h"
#import "CoreDataManager.h"

@implementation RootViewController

@synthesize locationArray = _locationArray;
@synthesize locationManager = _locationManager;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Start the location manager.
	[[self locationManager] startUpdatingLocation];

    // Set the title.
    self.title = @"Locations";

	// Configure the add and edit buttons.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    self.navigationItem.leftBarButtonItem = actionButton;
    actionButton.enabled = NO;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        @synchronized([CoreDataManager class])
        {
            BOOL setupSecceeded = [Utilities setupTables];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                if (setupSecceeded) {
                    [self loadFromCD];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"There was a problem during setup, check application log for details" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }

                actionButton.enabled = YES;
            });
        }
    });
}

- (void)loadFromCD
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        self.locationArray = [[CoreDataManager sharedInstance] listLocations];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

- (void)viewDidUnload {
	// Release any properties that are loaded in viewDidLoad or can be recreated lazily.
	self.locationArray = nil;
	self.locationManager = nil;
}

#pragma mark -
#pragma mark Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Only one section.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// As many rows as there are obects in the events array.
    return [self.locationArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSNumberFormatter *nf = nil;
	if (nf == nil) {
		nf = [NSNumberFormatter new];
		[nf setNumberStyle:NSNumberFormatterDecimalStyle];
	}

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	// Get the event corresponding to the current index path and configure the table view cell.
	Location *loc = (Location *)[self.locationArray objectAtIndex:indexPath.row];

    cell.textLabel.text =  [NSString stringWithFormat:@"%@ (%d)", loc.name, loc.checkins.count];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"Lat: %@, Lng: %@", loc.lat, loc.lng];

	return cell;
}

/**
 * Handle deletion of an event.
 */

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            // Delete the managed object at the given index path.
            Location *locToDelete = (Location *)[self.locationArray objectAtIndex:indexPath.row];

            [[CoreDataManager sharedInstance] deleteLocation:locToDelete];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                // Update the array and table view.
                [self.locationArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            });
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Location *locToUpdate = [self.locationArray objectAtIndex:indexPath.row];

    CheckinsViewController *checkinsViewController = [CheckinsViewController alloc];
    checkinsViewController.location = locToUpdate;

    [self.navigationController pushViewController:checkinsViewController animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Location manager

/**
 * Return a location manager -- create one if necessary.
 */
- (CLLocationManager *)locationManager {

    if (_locationManager != nil) {
		return _locationManager;
	}

	_locationManager = [[CLLocationManager alloc] init];
	[_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
	[_locationManager setDelegate:self];

	return _locationManager;
}

#pragma mark - User Actions

- (void)showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add", @"Save", @"Undo", nil];
    [actionSheet showInView:self.view];
}

- (void)addLocation {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Location" message:@"Give this location a name" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *name = [alertView textFieldAtIndex:0].text;
    NSLog(@"%@", name);

    if ((name == nil) || [name isEqualToString:@""]) {
        return;
    }

	// If it's not possible to get a location, then return.
	CLLocation *location = [self.locationManager location];
	if (!location) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Unable to determine your location.  Make sure Locations Services is enabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
		return;
	}

    CLLocationCoordinate2D coordinate = [location coordinate];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        // Create a new instance of the Checkin entity.
        Checkin *checkin = [[CoreDataManager sharedInstance] createCheckinWithComment:@"First Checkin"];
        Location *loc = [[CoreDataManager sharedInstance] createLocationWithName:name];
        checkin.location = loc;

        // Configure the new event with information from the location.
        loc.lat = [NSNumber numberWithDouble:coordinate.latitude];
        loc.lng = [NSNumber numberWithDouble:coordinate.longitude];
        [loc addCheckinsObject:checkin];

        // Since this is a new event, and events are displayed with most recent events at the top of the list,
        // add the new event to the beginning of the events array; then redisplay the table view.
        [self.locationArray insertObject:loc atIndex:0];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

            [self.tableView reloadData];
        });
    });
}

- (void)saveAll
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        BOOL saved = [[CoreDataManager sharedInstance] saveAllLocations:self.locationArray];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if (saved) {
                [self.tableView reloadData];

                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS"
                                                                message:@"Successfully saved changes."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                                                message:@"There was a problem saving data, check application log for details"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
        });
    });
}

- (void)undo
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        [[CoreDataManager sharedInstance].managedObjectContext.undoManager undo];
        [self cleanUpLocationArray];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            [self.tableView reloadData];
        });
    });
}

#pragma mark - Helper Methods

- (void)cleanUpLocationArray
{
    [self loadFromCD];
}

#pragma mark - UIActionSheet Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self addLocation];
            break;
            
        case 1:
            [self saveAll];
            break;
            
        case 2:
            [self undo];
            break;
            
        default:
            break;
    }
}

@end