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

#import "CognitoDatasetListViewController.h"
#import "CognitoDatasetViewController.h"
#import <AWSCognito/AWSCognito.h>
#import "AWSLogging.h"

@interface CognitoDatasetListViewController () {
    NSMutableArray *_datasets;
}
@end

@implementation CognitoDatasetListViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _datasets = [NSMutableArray arrayWithArray:[[AWSCognito defaultCognito] listDatasets]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createNewDataset:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"New Dataset" message:@"Enter a new dataset name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)refreshClicked:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:_datasets.count];
    
    for (AWSCognitoDatasetMetadata *metadata in _datasets) {
        AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:metadata.name];
        [tasks addObject:[dataset synchronize]];
    }
    
    [[[AWSTask taskForCompletionOfAllTasks:tasks] continueWithBlock:^id(AWSTask *task) {
        return [[AWSCognito defaultCognito] refreshDatasetMetadata];
    }] continueWithBlock:^id(AWSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (task.error) {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:task.error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
            else {
                _datasets = [NSMutableArray arrayWithArray:[[AWSCognito defaultCognito] listDatasets]];
                [self.tableView reloadData];
            }
        });
        return nil;
    }];
}


#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *datasetName = [alertView textFieldAtIndex:0].text;
        if (datasetName != nil) {
            AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetName];
            [_datasets addObject:dataset];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_datasets count]-1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datasets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    AWSCognitoDatasetMetadata *dataset = [_datasets objectAtIndex:indexPath.row];
    cell.textLabel.text = dataset.name;
    if ([dataset isDeleted]) {
        cell.textLabel.attributedText = [[NSAttributedString alloc] initWithString:dataset.name
                                                                        attributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)}];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AWSCognitoDatasetMetadata *datasetMetadata = [_datasets objectAtIndex:indexPath.row];
        AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetMetadata.name];
        [dataset clear];
        [_datasets replaceObjectAtIndex:indexPath.row withObject:dataset];
        [self.tableView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDataset"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AWSCognitoDatasetMetadata *datasetMetadata = [_datasets objectAtIndex:indexPath.row];
        AWSCognitoDataset *dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetMetadata.name];
        CognitoDatasetViewController *controller = [segue destinationViewController];
        controller.dataset = dataset;
        AWSCognitoCredentialsProvider *provider = [[[AWSCognito defaultCognito] configuration] credentialsProvider];
        controller.identityId = provider.identityId;
    }
}

@end
