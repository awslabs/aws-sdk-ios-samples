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

#import "EndpointsListTableViewController.h"
#import "MessageBoard.h"
@interface EndpointsListTableViewController ()

@end

@implementation EndpointsListTableViewController


-(void)switchChanged:(UISwitch *)sender{
    
    int row = sender.tag;
    
    SNSEndpoint *aEndpoint = self.endpointListsArray[row];
    NSString *isEnabled = sender.on?@"true":@"false";
    NSMutableDictionary *attributesDic = [NSMutableDictionary dictionaryWithObject:isEnabled forKey:@"Enabled"];
    [[MessageBoard instance] updateEndpointAttributesWithendPointARN:aEndpoint.endpointArn Attributes:attributesDic];
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Endpoints List";
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
        
        self.endpointListsArray = [[[MessageBoard instance] listEndpoints] retain];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.tableView reloadData];
        });
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.endpointListsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        
        //add a switch
        UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
        [switchview addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchview;
        [switchview release];
    }
    
    // Configure the cell...
    SNSEndpoint *endpoint = [self.endpointListsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = endpoint.endpointArn;
    
    NSMutableDictionary *endpointAttributesDic =  endpoint.attributes;
    bool enpointIsEnabled = [[endpointAttributesDic objectForKey:@"Enabled"] boolValue];
    UISwitch *aSwitch = (UISwitch*)cell.accessoryView;
    aSwitch.tag = indexPath.row;
    aSwitch.on = enpointIsEnabled;
    
    if ([endpoint.endpointArn isEqualToString:[[MessageBoard instance] findEndpointARN]]) {
        cell.textLabel.textColor= [UIColor redColor];
    }else {
        cell.textLabel.textColor= [UIColor blackColor];
    }
    
    return cell;
     
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        

        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            });
            
            
            SNSEndpoint *endpoint = [self.endpointListsArray objectAtIndex:indexPath.row];
            
            [[MessageBoard instance] removeEndpoint:endpoint.endpointArn];
            
            [self.endpointListsArray removeObjectAtIndex:indexPath.row];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView endUpdates];
            });
        });
        
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}




@end
