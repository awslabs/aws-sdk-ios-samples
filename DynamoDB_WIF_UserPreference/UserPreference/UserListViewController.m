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

#import "UserListViewController.h"
#import "DynamoDBManager.h"
#import "UserViewController.h"

@implementation UserListView

@synthesize users;

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.users = nil;
        self.title = @"User List";
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
    return self;
}

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        self.users = [DynamoDBManager getUserList];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            [self.tableView reloadData];
        });
    });
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellStateShowingEditControlMask;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           ((DynamoDBAttributeValue *)[[self.users objectAtIndex:indexPath.row] objectForKey:@"firstName"]).s,
                           ((DynamoDBAttributeValue *)[[self.users objectAtIndex:indexPath.row] objectForKey:@"lastName"]).s];    

    return cell;
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

            [DynamoDBManager deleteUser:(DynamoDBAttributeValue *)[[self.users objectAtIndex:indexPath.row] objectForKey:@"userNo"]];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                [self.users removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:YES];
            });
        });
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserViewController *userView = [[UserViewController alloc] initWithStyle:UITableViewStyleGrouped];

    userView.userNo = [((DynamoDBAttributeValue *)[[self.users objectAtIndex:indexPath.row] objectForKey:@"userNo"]).n intValue];
    [self.navigationController pushViewController:userView animated:YES];
    [userView release];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
