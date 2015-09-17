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

#import "DDBMainViewController.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import "DDBDetailViewController.h"
#import "DDBDynamoDBManager.h"
#import "DDBSearchViewController.h"

@interface DDBMainViewController ()

@property (nonatomic, readonly) NSMutableArray *tableRows;
@property (nonatomic, readonly) NSLock *lock;
@property (nonatomic, strong) NSDictionary *lastEvaluatedKey;
@property (nonatomic, assign) BOOL doneLoading;

@end

@implementation DDBMainViewController

-(IBAction)unwindToMainViewControllerFromSearchViewController:(UIStoryboardSegue *)unwindSegue {
    
    DDBSearchViewController *searchVC = (DDBSearchViewController *)[unwindSegue sourceViewController];
    [self.tableRows removeAllObjects];
    for (DDBTableRow *item in searchVC.paginatedOutput.items) {
        [self.tableRows addObject:item];
    }
    self.doneLoading = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
#pragma mark - DynamoDB management

- (void)setupTable {
    // See if the test table exists.
    [[DDBDynamoDBManager describeTable]
     continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
         // If the test table doesn't exist, create one.
         if ([task.error.domain isEqualToString:AWSDynamoDBErrorDomain]
             && task.error.code == AWSDynamoDBErrorResourceNotFound) {
             [self performSegueWithIdentifier:@"DDBLoadingViewSegue"
                                       sender:self];

             return [[DDBDynamoDBManager createTable]
                     continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                         // Handle errors.
                         if (task.error) {
                             NSLog(@"Error: [%@]", task.error);

                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                             message:@"Failed to setup a test table."
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil];
                             [alert show];

                         } else {
                             [self dismissViewControllerAnimated:NO completion:nil];
                         }

                         return nil;
                     }];
         } else {
             //load table contents
             [self refreshList:YES];
         }

         return nil;
     }];
}

- (AWSTask *)refreshList:(BOOL)startFromBeginning {
    if ([self.lock tryLock]) {
        if (startFromBeginning) {
            self.lastEvaluatedKey = nil;
            self.doneLoading = NO;
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

        AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
        scanExpression.exclusiveStartKey = self.lastEvaluatedKey;
        scanExpression.limit = @20;

        return [[[dynamoDBObjectMapper scan:[DDBTableRow class]
                                  expression:scanExpression]
                 continueWithExecutor:[AWSExecutor mainThreadExecutor] withSuccessBlock:^id(AWSTask *task) {
                     if (!self.lastEvaluatedKey) {
                         [self.tableRows removeAllObjects];
                     }

                     AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                     for (DDBTableRow *item in paginatedOutput.items) {
                         [self.tableRows addObject:item];
                     }

                     self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey;
                     if (!paginatedOutput.lastEvaluatedKey) {
                         self.doneLoading = YES;
                     }

                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                     [self.tableView reloadData];

                     return nil;
                 }] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
                     if (task.error) {
                         NSLog(@"Error: [%@]", task.error);
                     }

                     [self.lock unlock];
                     
                     return nil;
                 }];
    }

    return nil;
}

- (void)deleteTableRow:(DDBTableRow *)row {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper remove:row]
     continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

         if (task.error) {
             NSLog(@"Error: [%@]", task.error);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to delete a row."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];

             [self.tableView reloadData];
         }

         return nil;
     }];
}

- (void)generateTestData {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];

    NSMutableArray *tasks = [NSMutableArray array];
    NSArray *gameTitleArray = @[@"Galaxy Invaders",@"Meteor Blasters", @"Starship X", @"Alien Adventure",@"Attack Ships"];
    for (int32_t i = 0; i < 25; i++) {
        for (int32_t j = 0 ; j < 2; j++) {
            DDBTableRow *tableRow = [DDBTableRow new];
            tableRow.UserId = [NSString stringWithFormat:@"%d",i];
            
            tableRow.GameTitle = j==0?gameTitleArray[arc4random_uniform((u_int32_t)gameTitleArray.count)]:@"Comet Quest";
            tableRow.TopScore = [NSNumber numberWithInt:arc4random_uniform(3000)];
            tableRow.Wins = [NSNumber numberWithInteger:arc4random_uniform(100)];
            tableRow.Losses = [NSNumber numberWithInteger:arc4random_uniform(100)];
            
            //Those two properties won't be saved to DynamoDB since it has been defined in ignoredAttributes
            tableRow.internalName =[NSString stringWithFormat:@"internal attributes(should not be saved to dynamoDB)"];
            tableRow.internalState = [NSNumber numberWithInt:i];
            
            [tasks addObject:[dynamoDBObjectMapper save:tableRow]];
        }
    }

    [[AWSTask taskForCompletionOfAllTasks:tasks]
     continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"Error: [%@]", task.error);
         }

         [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

         return [self refreshList:YES];
     }];
}

#pragma mark - Action sheet

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Your Action"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:
                                  @"Add",
                                  self.tableView.editing ? @"End Editing" : @"Edit",
                                  @"Generate Test Data",
                                  @"Refresh", nil];
    [actionSheet showInView:self.tableView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"DDBSeguePushDetailViewController"
                                      sender:actionSheet];
            break;

        case 1:
            if (self.tableView.editing) {
                self.tableView.editing = NO;
            } else {
                self.tableView.editing = YES;
            }
            break;

        case 2:
            [self generateTestData];
            break;

        case 3:
            [self refreshList:YES];
            break;

        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    DDBTableRow *item = self.tableRows[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"ID: %@, Title: %@",item.UserId,item.GameTitle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"TopScore:%@, Wins:%@, Losses:%@",item.TopScore,item.Wins,item.Losses];

    if (indexPath.row == [self.tableRows count] - 1 && !self.doneLoading) {
        [self refreshList:NO];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DDBTableRow *row = self.tableRows[indexPath.row];
        [self deleteTableRow:row];

        [self.tableRows removeObject:row];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"DDBSeguePushDetailViewController"
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DDBDetailViewController *detailViewController = [segue destinationViewController];
    if ([sender isKindOfClass:[UIActionSheet class]]) {
        detailViewController.viewType = DDBDetailViewTypeInsert;
    } else if ([sender isKindOfClass:[UITableViewCell class]]) {
        detailViewController.viewType = DDBDetailViewTypeUpdate;

        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        DDBTableRow *tableRow = [self.tableRows objectAtIndex:indexPath.row];
        detailViewController.tableRow = tableRow;
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableRows = [NSMutableArray new];
    _lock = [NSLock new];
    
    [self setupTable];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.needsToRefresh) {
        [self refreshList:YES];
        self.needsToRefresh = NO;
    }
}

@end
