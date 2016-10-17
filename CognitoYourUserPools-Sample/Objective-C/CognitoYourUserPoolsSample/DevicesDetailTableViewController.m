//
// Copyright 2014-2016 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

#import "DevicesDetailTableViewController.h"
#import "AWSCognitoIdentityProvider.h"


@interface DevicesDetailTableViewController ()
@property (nonatomic,strong) AWSCognitoIdentityUserListDevicesResponse * response;
@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@end

@implementation DevicesDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    //on initial load set the user and refresh to get devices
    if(!self.user)
        self.user = [self.pool currentUser];
    [self refresh];
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.response.devices[section].deviceKey;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.response.devices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.response){
        return self.response.devices[section].deviceAttributes.count+3;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attribute" forIndexPath:indexPath];
    AWSCognitoIdentityProviderDeviceType * device = self.response.devices[indexPath.section];
    if(indexPath.row < 3){
        switch(indexPath.row){
            case 0:
                cell.textLabel.text = @"Create Date";
                cell.detailTextLabel.text = [formatter stringFromDate:device.deviceCreateDate];
                break;
            case 1:
                cell.textLabel.text = @"Last Authenticated";
                cell.detailTextLabel.text = [formatter stringFromDate:device.deviceLastAuthenticatedDate];
                break;
            case 2:
                cell.textLabel.text = @"Last Modified";
                cell.detailTextLabel.text = [formatter stringFromDate:device.deviceLastModifiedDate];
                break;
        }
    }else {
        AWSCognitoIdentityProviderAttributeType *attribute = device.deviceAttributes[indexPath.row-3];
        cell.textLabel.text = attribute.name;
        cell.detailTextLabel.text = attribute.value;
    }
    return cell;
}

-(void) refresh {
    [[self.user listDevices:10 paginationToken:nil] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserListDevicesResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.response = task.result;
            self.title = @"Devices";
            [self.tableView reloadData];
        });
        return nil;
    }];
}
- (IBAction)forgetDevice:(UIBarButtonItem *)sender {
    if(self.response && self.response.devices.count > 0){
        [[self.user forgetDevice] continueWithBlock:
        ^id _Nullable(AWSTask * _Nonnull task) {
            if(task.error){
                    [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                                message:task.error.userInfo[@"message"]
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"Ok", nil] show];
            }
            
            [self refresh];
            return nil;
        }];
    }
}

@end
