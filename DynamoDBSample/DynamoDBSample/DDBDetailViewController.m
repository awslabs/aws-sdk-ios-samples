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

#import "DDBDetailViewController.h"

#import "DynamoDB.h"
#import "DDBDynamoDBManager.h"
#import "DDBMainViewController.h"

@interface DDBDetailViewController ()

@property (nonatomic, assign) BOOL dataChanged;

@end

@implementation DDBDetailViewController

- (void)getTableRow:(NSString *)rangeKey {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper load:[DDBTableRow class]
                        hashKey:[[UIDevice currentDevice].identifierForVendor UUIDString]
                       rangeKey:rangeKey] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (!task.error) {
            DDBTableRow *tableRow = task.result;

            self.rangeKeyTextField.text = tableRow.rangeKey;
            self.attribute1TextField.text = tableRow.attribute1;
            self.attribute2TextField.text = tableRow.attribute2;
            self.attribute3TextField.text = tableRow.attribute3;
        } else {
            NSLog(@"Error: [%@]", task.error);

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Failed to get item from the table."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];

        }
        return nil;
    }];
}

- (void)insertTableRow:(DDBTableRow *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper save:tableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"Successfully inserted the data into the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];

             self.rangeKeyTextField.text = nil;
             self.attribute1TextField.text = nil;
             self.attribute2TextField.text = nil;
             self.attribute3TextField.text = nil;

             self.dataChanged = YES;
         } else {
             NSLog(@"Error: [%@]", task.error);

             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to insert the data into the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }

         return nil;
     }];
}

- (void)updateTableRow:(DDBTableRow *)tableRow {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper save:tableRow]
     continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
         if (!task.error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succeeded"
                                                             message:@"Successfully updated the data in the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];

             if (self.viewType == DDBDetailViewTypeInsert) {
                 self.rangeKeyTextField.text = nil;
                 self.attribute1TextField.text = nil;
             }

             self.dataChanged = YES;
         } else {
             NSLog(@"Error: [%@]", task.error);

             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                             message:@"Failed to update the data in the table."
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }

         return nil;
     }];
}

- (IBAction)submit:(id)sender {
    DDBTableRow *tableRow = [DDBTableRow new];
    tableRow.rangeKey = self.rangeKeyTextField.text;
    tableRow.attribute1 = self.attribute1TextField.text;
    tableRow.attribute2 = self.attribute2TextField.text;
    tableRow.attribute3 = self.attribute3TextField.text;

    switch (self.viewType) {
        case DDBDetailViewTypeInsert:
            if ([self.rangeKeyTextField.text length] > 0) {
                [self insertTableRow:tableRow];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error: Invalid Input"
                                                                    message:@"Range Key Value cannot be empty."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }

            break;

        case DDBDetailViewTypeUpdate:
            if ([self.rangeKeyTextField.text length] > 0) {
                [self updateTableRow:tableRow];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error: Invalid Input"
                                                                    message:@"Range Key Value cannot be empty."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
            }

            break;

        default:
            NSAssert(YES, @"Invalid viewType.");
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    switch (self.viewType) {
        case DDBDetailViewTypeInsert:
            self.title = @"Insert";
            self.rangeKeyTextField.enabled = YES;

            break;

        case DDBDetailViewTypeUpdate:
            self.title = @"Update";
            self.rangeKeyTextField.enabled = NO;
            [self getTableRow:self.tableRow.rangeKey];

            break;

        default:
            NSAssert(YES, @"Invalid viewType.");
            break;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.dataChanged) {
        DDBMainViewController *mainViewController = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count] - 1];
        mainViewController.needsToRefresh = YES;
    }
}

@end
