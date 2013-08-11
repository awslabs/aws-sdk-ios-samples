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

#import "BucketList.h"
#import <AWSS3/AWSS3.h>
#import "AddBucketViewController.h"
#import "AmazonClientManager.h"
#import "ObjectListing.h"

@implementation BucketList

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Bucket List";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        NSArray *bucketNames = [[AmazonClientManager s3] listBuckets];
        if (buckets == nil) {
            buckets = [[NSMutableArray alloc] initWithCapacity:[bucketNames count]];
        }
        else {
            [buckets removeAllObjects];
        }

        if (bucketNames != nil) {
            for (S3Bucket *bucket in bucketNames) {
                [buckets addObject:[bucket name]];
            }
        }

        [buckets sortUsingSelector:@selector(compare:)];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
}

-(void)add:(id)sender
{
    AddBucketViewController *addBucketViewController = [[AddBucketViewController alloc] init];
    [self presentModalViewController:addBucketViewController animated:YES];
    [addBucketViewController release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [buckets count];
}

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
    cell.textLabel.text = [buckets objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            S3DeleteBucketRequest *deleteBucketRequest = [[[S3DeleteBucketRequest alloc] initWithName:[buckets objectAtIndex:indexPath.row]] autorelease];
            S3DeleteBucketResponse *deleteBucketResponse = [[AmazonClientManager s3] deleteBucket:deleteBucketRequest];
            if(deleteBucketResponse.error != nil)
            {
                NSLog(@"Error: %@", deleteBucketResponse.error);
            }

            [buckets removeObjectAtIndex:indexPath.row];

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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ObjectListing *objectList = [[ObjectListing alloc] init];
    objectList.bucket = [buckets objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:objectList animated:YES];
    [objectList release];
}

-(void)dealloc
{
    [buckets release];
    [super dealloc];
}


@end

