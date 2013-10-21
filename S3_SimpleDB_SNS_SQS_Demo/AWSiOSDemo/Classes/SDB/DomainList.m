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

#import "DomainList.h"
#import "AmazonClientManager.h"
#import "ItemListing.h"

@implementation DomainList

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Domain List";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        SimpleDBListDomainsRequest  *listDomainsRequest  = [[[SimpleDBListDomainsRequest alloc] init] autorelease];
        SimpleDBListDomainsResponse *listDomainsResponse = [[AmazonClientManager sdb] listDomains:listDomainsRequest];
        if(listDomainsResponse.error != nil)
        {
            NSLog(@"Error: %@", listDomainsResponse.error);
        }

        if (domains == nil) {
            domains = [[NSMutableArray alloc] initWithCapacity:[listDomainsResponse.domainNames count]];
        }
        else {
            [domains removeAllObjects];
        }
        
        for (NSString *name in listDomainsResponse.domainNames) {
            [domains addObject:name];
        }

        [domains sortUsingSelector:@selector(compare:)];
        
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
    return [domains count];
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
    cell.textLabel.text = [domains objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ItemListing *itemList = [[ItemListing alloc] initWithStyle:UITableViewStylePlain];
    itemList.domain = [domains objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:itemList animated:YES];
    [itemList release];
}

-(void)dealloc
{
    [domains release];
    [super dealloc];
}


@end

