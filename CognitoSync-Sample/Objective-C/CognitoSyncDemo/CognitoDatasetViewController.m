/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "CognitoDatasetViewController.h"
#import "Cognito.h"

const int AWSCognitoNewRecordView = 1;
const int AWSCognitoUpdateRecordView = 2;

@interface CognitoDatasetViewController () {
    NSMutableArray *_objects;
    NSString *_selectedRecord;
}
@end

@implementation CognitoDatasetViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self refreshTapped:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (void)getRecords {
    NSArray *temp = [NSMutableArray arrayWithArray:[self.dataset getAllRecords]];
    _objects = [NSMutableArray arrayWithCapacity:temp.count];
    
    for (AWSCognitoRecord *record in temp) {
        if (!record.isDirty && (record.data.string == nil || record.data.string.length == 0)) {
            continue;
        }
        [_objects addObject:record];
    }
}

- (IBAction)insertNewObject:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Record" message:@"Enter a new record name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = AWSCognitoNewRecordView;
    [alertView show];
}

- (IBAction)refreshTapped:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self.dataset synchronize] continueWithBlock:^id(BFTask *task) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self getRecords];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        return nil;
    }];
}


- (IBAction)populateClicked:(id)sender {
    int numReconds = 20;
    for (int i = 0; i < numReconds; i++) {
        NSString *value = [NSString stringWithFormat:@"value%d", i];
        NSString *key = [NSString stringWithFormat:@"key%d", i];
        [self.dataset setString:value forKey:key];
    }
    [self getRecords];
    [self.tableView reloadData];
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == AWSCognitoNewRecordView && buttonIndex == 1) {
        
        NSString *recordName = [alertView textFieldAtIndex:0].text;
        if (recordName != nil && [self.dataset stringForKey:recordName] == nil) {
            [self.dataset setString:@" " forKey:recordName];
            _objects = [NSMutableArray arrayWithArray:[self.dataset getAllRecords]];
            [self.tableView reloadData];
        }
    }
    else if (alertView.tag == AWSCognitoUpdateRecordView && buttonIndex == 1) {
        NSString *recordValue = [alertView textFieldAtIndex:0].text;
        if (recordValue != nil) {
            [self.dataset setString:recordValue forKey:_selectedRecord];
            _selectedRecord = nil;
            _objects = [NSMutableArray arrayWithArray:[self.dataset getAllRecords]];
            [self.tableView reloadData];
        }
        
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    AWSCognitoRecord *object = _objects[indexPath.row];
    cell.textLabel.text = object.recordId;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: SyncCount:%lld",object.data.string, object.syncCount];
    cell.detailTextLabel.textColor = object.isDirty? [UIColor redColor] : [UIColor blackColor];
    
    if ([object isDeleted]) {
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:object.recordId
                                                                        attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AWSCognitoRecord *record = [_objects objectAtIndex:indexPath.row];
        [self.dataset removeObjectForKey:record.recordId];
        [self getRecords];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AWSCognitoRecord *record = [_objects objectAtIndex:indexPath.row];
    _selectedRecord = record.recordId;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Value" message:@"Enter a new value" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = AWSCognitoUpdateRecordView;
    [alertView show];
}

@end
