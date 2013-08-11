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

#import <AWSS3/AWSS3.h>
#import "AddObjectViewController.h"
#import "ObjectViewController.h"
#import "AmazonClientManager.h"

@implementation ObjectListing

@synthesize bucket = _bucket;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Objects";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        S3ListObjectsRequest  *listObjectRequest = [[[S3ListObjectsRequest alloc] initWithName:self.bucket] autorelease];
        S3ListObjectsResponse *listObjectResponse = [[AmazonClientManager s3] listObjects:listObjectRequest];
        if(listObjectResponse.error != nil)
        {
            NSLog(@"Error: %@", listObjectResponse.error);
            [objects addObject:@"Unable to load objects!"];
        }
        else
        {
            S3ListObjectsResult *listObjectsResults = listObjectResponse.listObjectsResult;

            if (objects == nil) {
                objects = [[NSMutableArray alloc] initWithCapacity:[listObjectsResults.objectSummaries count]];
            }
            else {
                [objects removeAllObjects];
            }

            // By defrault, listObjects will only return 1000 keys
            // This code will fetch all objects in bucket.
            // NOTE: This could cause the application to run out of memory
            NSString *lastKey = @"";
            for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                [objects addObject:[objectSummary key]];
                lastKey = [objectSummary key];
            }

            while (listObjectsResults.isTruncated) {
                listObjectRequest = [[[S3ListObjectsRequest alloc] initWithName:self.bucket] autorelease];
                listObjectRequest.marker = lastKey;

                listObjectResponse = [[AmazonClientManager s3] listObjects:listObjectRequest];
                if(listObjectResponse.error != nil)
                {
                    NSLog(@"Error: %@", listObjectResponse.error);
                    [objects addObject:@"Unable to load objects!"];

                    break;
                }

                listObjectsResults = listObjectResponse.listObjectsResult;

                for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                    [objects addObject:[objectSummary key]];
                    lastKey = [objectSummary key];
                }
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
}

-(void)add:(id)sender
{
    AddObjectViewController *addObject = [[AddObjectViewController alloc] init];
    addObject.bucket               = self.bucket;
    [self presentModalViewController:addObject animated:YES];
    [addObject release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objects count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Configure the cell...
    cell.textLabel.text = [objects objectAtIndex:indexPath.row];

    return cell;
}

// Override to support conditional editing of the table view.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ObjectViewController *objectView = [[ObjectViewController alloc] initWithNibName:@"ObjectViewController" bundle:nil];
    objectView.bucket = self.bucket;
    objectView.objectName = [objects objectAtIndex:indexPath.row];

    [self presentModalViewController:objectView animated:YES];
    [objectView release];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            S3DeleteObjectRequest *dor = [[[S3DeleteObjectRequest alloc] init] autorelease];
            dor.bucket = self.bucket;
            dor.key    = [objects objectAtIndex:indexPath.row];

            S3DeleteObjectResponse *deleteObjectResponse = [[AmazonClientManager s3] deleteObject:dor];
            if(deleteObjectResponse.error != nil)
            {
                NSLog(@"Error: %@", deleteObjectResponse.error);
            }

            [objects removeObjectAtIndex:indexPath.row];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            });
        });
    }
}

-(void)dealloc
{
    [objects release];
    [_bucket release];
    
    [super dealloc];
}

@end