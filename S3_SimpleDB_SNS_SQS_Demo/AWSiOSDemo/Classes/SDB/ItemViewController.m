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
#import "ItemViewController.h"
#import "AmazonClientManager.h"

@implementation ItemViewController

@synthesize domain, itemName;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Item";
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        SimpleDBGetAttributesRequest *gar = [[[SimpleDBGetAttributesRequest alloc] initWithDomainName:self.domain andItemName:self.itemName] autorelease];
        SimpleDBGetAttributesResponse *response = [[AmazonClientManager sdb] getAttributes:gar];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
        }

        if (data == nil) {
            data = [[NSMutableArray alloc] initWithCapacity:[response.attributes count]];
        }
        else {
            [data removeAllObjects];
        }

        for (SimpleDBAttribute *attr in response.attributes) {
            [data addObject:[NSString stringWithFormat:@"%@ => %@", attr.name, attr.value]];
        }

        [data sortUsingSelector:@selector(compare:)];
        
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
    return [data count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;        
    }
    
    cell.textLabel.text = [data objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)dealloc
{
    [data release];
    [itemName release];
    [domain release];
    [super dealloc];
}

@end