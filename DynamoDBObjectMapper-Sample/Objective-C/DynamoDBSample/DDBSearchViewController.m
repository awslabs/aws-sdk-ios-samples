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

#import "DDBSearchViewController.h"
#import "DDBDynamoDBManager.h"

@interface DDBSearchViewController ()

@property (nonatomic, strong) NSArray *pickerData;
@end

@implementation DDBSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _pickerData = @[@"Comet Quest",@"Galaxy Invaders",@"Meteor Blasters", @"Starship X", @"Alien Adventure",@"Attack Ships"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)searchBtnPressed:(id)sender {
    
    Class queryClass = nil;
    
    switch (self.sortSegControl.selectedSegmentIndex) {
        case 0:
            queryClass = [DDBTableRowTopScore class];
            break;
        case 1:
            queryClass = [DDBTableRowWins class];
            break;
        case 2:
            queryClass = [DDBTableRowLosses class];
            break;
        default:
            break;
    }
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    //Query using gsi index table
    //What is the top score ever recorded for the game Meteor Blasters?
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.hashKeyValues = [self.pickerData objectAtIndex:[self.gameTitlePickerView selectedRowInComponent:0]];
    queryExpression.scanIndexForward = self.orderSegControl.selectedSegmentIndex==0?@YES:@NO;
    queryExpression.indexName = [self.sortSegControl titleForSegmentAtIndex:self.sortSegControl.selectedSegmentIndex]; //using indexTable for query
    [[dynamoDBObjectMapper query:queryClass expression:queryExpression] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            NSLog(@"Error: [%@]", task.error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Failed to query a test table."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            });
                          
        } else {
            self.paginatedOutput = task.result;
             [self performSegueWithIdentifier:@"unwindToMainSegue" sender:self];
        }
        
        return nil;
    }];
}

#pragma mark - UIPickerViewDataSource Delegate Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerData[row];
}

@end
