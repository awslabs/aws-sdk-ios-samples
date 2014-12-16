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

#import <AWSS3/AWSS3.h>
#import "AddObjectViewController.h"
#import "ObjectViewController.h"
#import "AmazonClientManager.h"
#import "AmazonKeyChainWrapper.h"

@implementation ObjectListing

@synthesize bucket, prefix;

-(id)init
{
    return [super initWithNibName:@"ObjectListing" bundle:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        S3ListObjectsRequest  *listObjectRequest = [[[S3ListObjectsRequest alloc] initWithName:self.bucket] autorelease];
        listObjectRequest.prefix = [NSString stringWithFormat:@"%@/", prefix];

        S3ListObjectsResponse *listObjectResponse = [[[AmazonClientManager sharedInstance] s3] listObjects:listObjectRequest];
        S3ListObjectsResult   *listObjectsResults = listObjectResponse.listObjectsResult;


        if (objects == nil) {
            objects = [[NSMutableArray alloc] initWithCapacity:[listObjectsResults.objectSummaries count]];
        }
        else {
            [objects removeAllObjects];
        }
        for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
            [objects addObject:[objectSummary key]];
        }
        [objects sortUsingSelector:@selector(compare:)];
    }
    @catch (AmazonClientException *exception)
    {
        NSLog(@"Exception = %@", exception);
        [[Constants errorAlert:[NSString stringWithFormat:@"Error list objects: %@", exception.message]] show];
    }

    [objectsTableView reloadData];
}

-(IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)add:(id)sender
{
    AddObjectViewController *addObject = [[AddObjectViewController alloc] init];

    addObject.bucket               = self.bucket;
    addObject.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

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
    }

    // Configure the cell...
    NSString *fullObjectName = [objects objectAtIndex:indexPath.row];
    NSRange range = [fullObjectName rangeOfString:[AmazonKeyChainWrapper username]];
    NSString *prunedName = [fullObjectName substringFromIndex:(range.location+ range.length + 1)];
    
    cell.textLabel.text                      = prunedName;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;

    return cell;
}

// Override to support conditional editing of the table view.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        ObjectViewController *objectView = [[ObjectViewController alloc] init];
        objectView.bucket               = self.bucket;
        objectView.objectName           = [objects objectAtIndex:indexPath.row];
        objectView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

        [self presentModalViewController:objectView animated:YES];
        [objectView release];
    }
    @catch (AmazonClientException *exception)
    {
        NSLog(@"Exception = %@", exception);
        [[Constants errorAlert:[NSString stringWithFormat:@"Error loading object: %@", exception.message]] show];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        @try {
            S3DeleteObjectRequest *dor = [[[S3DeleteObjectRequest alloc] init] autorelease];
            dor.bucket = self.bucket;
            dor.key    = [objects objectAtIndex:indexPath.row];

            [[[AmazonClientManager sharedInstance] s3] deleteObject:dor];
            [objects removeObjectAtIndex:indexPath.row];

            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];

            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        @catch (AmazonClientException *exception)
        {
            NSLog(@"Exception = %@", exception);
            [[Constants errorAlert:[NSString stringWithFormat:@"Error deleting object: %@", exception.message]] show];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

-(void)dealloc
{
    [objects release];
    [bucket release];
    [super dealloc];
}


@end

