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

#import "UserDetailTableViewController.h"
#import "AWSCognitoIdentityProvider.h"

@interface UserDetailTableViewController ()
@property (nonatomic,strong) AWSCognitoIdentityUserGetDetailsResponse * response;
@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@end

@implementation UserDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    //on initial load set the user and refresh to get attributes
    if(!self.user)
        self.user = [self.pool currentUser];
    [self refresh];
    

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.response){
        return self.response.userAttributes.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"attribute" forIndexPath:indexPath];
    
    AWSCognitoIdentityProviderAttributeType *userAttribute = self.response.userAttributes[indexPath.row];
    cell.textLabel.text = userAttribute.name;
    cell.detailTextLabel.text = userAttribute.value;
    return cell;
}

- (IBAction)signOut:(id)sender {
    [self.user signOut];
    [self refresh];
}

-(void) refresh {
    [[self.user getDetails] continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.response = task.result;
            self.title = self.user.username;
            [self.tableView reloadData];
        });
        return nil;
    }];
}

@end
