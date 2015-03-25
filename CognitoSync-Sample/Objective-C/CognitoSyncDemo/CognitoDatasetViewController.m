/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
#import <AWSCognito/AWSCognito.h>
#import "Constants.h"

const int AWSCognitoNewRecordView = 1;
const int AWSCognitoUpdateRecordView = 2;

@interface CognitoDatasetViewController () {
    NSMutableArray *_objects;
    NSString *_selectedRecord;
}
@property (weak, nonatomic) IBOutlet UISwitch *subscribeSwitch;

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [self.subscribeSwitch setOn:[@"Subscribed" isEqualToString:[userDefaults stringForKey:self.dataset.name]] animated:NO];
    [self refreshTapped:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePushSync:)
                                                 name:CognitoPushNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceivePushSync:(NSNotification*)notification
{
    NSDictionary * data = [(NSDictionary *)[notification object] objectForKey:@"data"];
    NSString * identityId = [data objectForKey:@"identityId"];
    NSString * datasetName = [data objectForKey:@"datasetName"];
    if([self.dataset.name isEqualToString:datasetName] && [self.identityId isEqualToString:identityId]){
        [self refreshTapped:nil];
    }
}

- (IBAction)subscribeClicked:(UISwitch *)sender {
    if(sender.on){
        [[self.dataset subscribe] continueWithBlock:^id(BFTask *task) {
            if(task.error){
                [self.subscribeSwitch setOn:NO animated:YES];
                NSLog(@"Unable to subscribe to dataset");
            }else {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults setObject:@"Subscribed" forKey: self.dataset.name];
                [userDefaults synchronize];
            }
            return nil;
        }];
    }else{
        [[self.dataset unsubscribe] continueWithBlock:^id(BFTask *task) {
            if(task.error){
                [self.subscribeSwitch setOn:YES animated:YES];
                NSLog(@"Unable to unsubscribe to dataset");
            }else {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                [userDefaults removeObjectForKey:self.dataset.name];
                [userDefaults synchronize];
            }
            return nil;
        }];
    }
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
