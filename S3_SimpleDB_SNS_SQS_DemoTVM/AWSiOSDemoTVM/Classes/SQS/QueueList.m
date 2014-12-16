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

#import "QueueList.h"
#import "AmazonClientManager.h"
#import "MessageList.h"
#import "AddQueue.h"

@implementation QueueList

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Queues";
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

-(void)add:(id)sender
{
    AddQueue *addQueue = [[AddQueue alloc] init];
    [self presentModalViewController:addQueue animated:YES];
    [addQueue release];
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        SQSListQueuesRequest  *listQueuesRequest = [[[SQSListQueuesRequest alloc] init] autorelease];
        SQSListQueuesResponse *response          = [[AmazonClientManager sqs] listQueues:listQueuesRequest];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
        }

        if (queues == nil) {
            queues = [[NSMutableArray alloc] initWithCapacity:[response.queueUrls count]];
        }
        else {
            [queues removeAllObjects];
        }
        
        for (NSString *queueName in response.queueUrls) {
            [queues addObject:queueName];
        }

        [queues sortUsingSelector:@selector(compare:)];

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
    return [queues count];
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
    cell.textLabel.text = [queues objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageList *messageList = [[MessageList alloc] init];
    messageList.queue = [queues objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:messageList animated:YES];
    [messageList release];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            SQSDeleteQueueRequest *deleteQueueRequest = [[[SQSDeleteQueueRequest alloc] initWithQueueUrl:[queues objectAtIndex:indexPath.row]] autorelease];
            SQSDeleteQueueResponse *deleteQueueResponse = [[AmazonClientManager sqs] deleteQueue:deleteQueueRequest];
            if(deleteQueueResponse.error != nil)
            {
                NSLog(@"Error: %@", deleteQueueResponse.error);
            }

            [queues removeObjectAtIndex:indexPath.row];

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            });
        });
    }
}

-(void)dealloc
{
    [queues release];
    [super dealloc];
}

@end