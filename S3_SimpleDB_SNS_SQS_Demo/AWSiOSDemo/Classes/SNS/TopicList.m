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

#import "TopicList.h"
#import "AmazonClientManager.h"

@implementation TopicList

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"SNS Topics";
}

-(void)viewWillAppear:(BOOL)animated
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        SNSListTopicsRequest  *listTopicsRequest = [[[SNSListTopicsRequest alloc] init] autorelease];
        SNSListTopicsResponse *response = [[AmazonClientManager sns] listTopics:listTopicsRequest];
        if(response.error != nil)
        {
            NSLog(@"Error: %@", response.error);
        }

        if (topics == nil) {
            topics = [[NSMutableArray alloc] initWithCapacity:[response.topics count]];
        }
        else {
            [topics removeAllObjects];
        }

        for (SNSTopic *topic in response.topics) {
            [topics addObject:topic.topicArn];
        }

        [topics sortUsingSelector:@selector(compare:)];

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
    return [topics count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
         cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }

    // Configure the cell...
    cell.textLabel.text = [topics objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"Topic Selected = %@", [topics objectAtIndex:indexPath.row]);
}

-(void)dealloc
{
    [topics release];
    [super dealloc];
}

@end