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
#import "CheckinsViewController.h"
#import "RootViewController.h"
#import "CoreDataManager.h"
#import "Utilities.h"
#import "Constants.h"

#import "Location.h"
#import "Checkin.h"

@implementation CheckinsViewController

@synthesize location = _location;
@synthesize checkinsArray = _checkinsArray;

- (void)mergeDeletedObject:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(processMergeDeletedObject:) withObject:notification waitUntilDone:YES];
}

- (void)processMergeDeletedObject:(NSNotification *)notification
{
    for(int i = [_checkinsArray count] - 1; i >= 0; i--)
    {
        Checkin *c = [_checkinsArray objectAtIndex:i];
        
        if([[c.objectID URIRepresentation] isEqual:[[notification.userInfo objectForKey:AWSPersistenceDynamoDBObjectDeletedNotificationObjectID] URIRepresentation]])
        {
            [_checkinsArray removeObjectAtIndex:i];
        }
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(mergeDeletedObject:) 
                                                 name:AWSPersistenceDynamoDBObjectDeletedNotification 
                                               object:nil];
    
    self.clearsSelectionOnViewWillAppear = NO;
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // put the contents of a set in an array for table view
    _checkinsArray = [[NSMutableArray alloc] initWithCapacity: self.location.checkins.count];
    for (Checkin *checkin in self.location.checkins) {
        [_checkinsArray addObject:checkin];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:AWSPersistenceDynamoDBObjectDeletedNotification 
                                                  object:nil];
    
    // Release any retained subviews of the main view.
    self.location = nil;
    self.checkinsArray = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _checkinsArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row < _checkinsArray.count) {
        // Get the event corresponding to the current index path and configure the table view cell.
        Checkin *checkin = (Checkin *)[_checkinsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", checkin.comment];
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"@ %@", checkin.checkinTime];
    }
    else {
        cell.textLabel.text = @"Add new...";
    }
	return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return indexPath.row < _checkinsArray.count;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            // Delete the managed object at the given index path.
            Checkin *checkin = (Checkin *)[_checkinsArray objectAtIndex:indexPath.row];
            [_location removeCheckinsObject:checkin];

            [[CoreDataManager sharedInstance] deleteCheckin:checkin];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                // Update the array and table view.
                [_checkinsArray removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            });
        });
    }  
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _checkinsArray.count) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin Comment" message:@"Add your comment" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = NEW_CHECKIN;
        [alert show];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Checkin Comment" message:@"Add your comment" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = indexPath.row;
        [alert show];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *comment = [alertView textFieldAtIndex:0].text;
    NSLog(@"%@", comment);
    if ((comment == nil) || [comment isEqualToString:@""]) {
        return;
    }
    
    if (alertView.tag == NEW_CHECKIN) {
        [self newCheckin:comment];
    }
    else {
        // Tag stores the index of this checkin
        [self modifyCheckin:alertView.tag withComment:comment];
    }
}

-(void)modifyCheckin:(NSInteger)checkinNo withComment:(NSString *)comment 
{
    // Modifying the checking is a simple operation
    Checkin *checkin = [_checkinsArray objectAtIndex:checkinNo];
    checkin.comment = comment;
    
    [self.tableView reloadData];
}

-(void)newCheckin:(NSString *)comment 
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        // Create a new checking object
        Checkin *checkin = [[CoreDataManager sharedInstance] createCheckinWithComment:comment];
        checkin.location = self.location;
        [self.location addCheckinsObject:checkin];
        [self.checkinsArray addObject:checkin];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            [self.tableView reloadData];
        });
    });
}

@end