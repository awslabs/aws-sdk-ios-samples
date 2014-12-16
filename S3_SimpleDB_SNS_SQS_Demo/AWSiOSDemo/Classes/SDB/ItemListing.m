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

#import <AWSSimpleDB/AWSSimpleDB.h>
#import "ItemListing.h"
#import "AmazonClientManager.h"
#import "ItemViewController.h"

@implementation ItemListing

@synthesize domain;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Items";
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        NSString *selectExpression = [NSString stringWithFormat:@"select itemName() from `%@`", self.domain];

        SimpleDBSelectRequest  *selectRequest  = [[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression] autorelease];
        SimpleDBSelectResponse *selectResponse = [[AmazonClientManager sdb] select:selectRequest];
        if(selectResponse.error != nil)
        {
            NSLog(@"Error: %@", selectResponse.error);
        }

        if (items == nil) {
            items = [[NSMutableArray alloc] initWithCapacity:[selectResponse.items count]];
        }
        else {
            [items removeAllObjects];
        }

        for (SimpleDBItem *item in selectResponse.items) {
            [items addObject:item.name];
        }

        [items sortUsingSelector:@selector(compare:)];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [items count];
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
    
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    ItemViewController *itemView = [[ItemViewController alloc] init];
    itemView.domain = self.domain;
    itemView.itemName = [items objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:itemView animated:YES];
    [itemView release];
}

-(void)dealloc
{
    [items release];
    [domain release];
    [super dealloc];
}

@end