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

#import "MessageList.h"
#import "SendMessage.h"
#import "AmazonClientManager.h"
#import "Message.h"

@implementation MessageList

@synthesize queue = _queue;
@synthesize messages = _messages;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Messages";
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(sendMessage:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    [sendButton release];
}

-(void)sendMessage:(id)sender
{
    SendMessage *sendMessage = [[SendMessage alloc] initWithNibName:@"SendMessage" bundle:nil];

    sendMessage.queue = self.queue;
    sendMessage.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    [self presentModalViewController:sendMessage animated:YES];
    [sendMessage release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        SQSReceiveMessageRequest *messageRequest = [[[SQSReceiveMessageRequest alloc] initWithQueueUrl:self.queue] autorelease];
        messageRequest.maxNumberOfMessages = [NSNumber numberWithInt:10];
        messageRequest.visibilityTimeout   = [NSNumber numberWithInt:1];
        SQSReceiveMessageResponse *messageResponse = [[AmazonClientManager sqs] receiveMessage:messageRequest];
        if(messageResponse.error != nil)
        {
            NSLog(@"Error: %@", messageResponse.error);
        }

        self.messages = messageResponse.messages;

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
    return [self.messages count];
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
    SQSMessage *message = (SQSMessage *)[self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = message.messageId;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *messageView = [[Message alloc] init];
    messageView.message = [self.messages objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:messageView animated:YES];
    [messageView release];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dispatchQueue, ^{

            dispatch_async(dispatch_get_main_queue(), ^{

                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });

            SQSMessage *selectedMessage = [self.messages objectAtIndex:indexPath.row];
            SQSDeleteMessageRequest *deleteMessageRequest = [[[SQSDeleteMessageRequest alloc] initWithQueueUrl:self.queue andReceiptHandle:selectedMessage.receiptHandle] autorelease];

            SQSDeleteMessageResponse *deleteMessageResponse = [[AmazonClientManager sqs] deleteMessage:deleteMessageRequest];
            if(deleteMessageResponse.error != nil)
            {
                NSLog(@"Error: %@", deleteMessageResponse.error);
            }

            [self.messages removeObjectAtIndex:indexPath.row];

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
    [_queue release];
    [_messages release];
    
    [super dealloc];
}

@end