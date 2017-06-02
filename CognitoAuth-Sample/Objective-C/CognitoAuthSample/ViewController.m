//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "ViewController.h"
#import "AWSCognitoAuth.h"

@interface ViewController () <AWSCognitoAuthDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signInButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *signOutButton;
@property (nonatomic, strong) AWSCognitoAuth * auth;
@property (nonatomic, strong) AWSCognitoAuthUserSession *session;
@property (nonatomic) BOOL firstLoad;
@end

@implementation ViewController

#pragma mark AWSCognitoAuthInteractiveAuthenticationDelegate
- (UIViewController *) getViewController {
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.auth = [AWSCognitoAuth defaultCognitoAuth];
    if([self.auth.authConfiguration.appClientId containsString:@"SETME"]){
        [self alertWithTitle:@"Error" message:@"Info.plist missing necessary config under AWS->CognitoUserPool->Default"];
    }
    self.auth.delegate = self;
    self.firstLoad = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.firstLoad){
        [self signInTapped:nil];
    }
    self.firstLoad = NO;
}

- (IBAction)signInTapped:(UIBarButtonItem *)sender {
    [self.auth getSession:self completion:^(AWSCognitoAuthUserSession * _Nullable session, NSError * _Nullable error) {
        if(error){
            [self alertWithTitle:@"Error" message:error.userInfo[@"error"]];
            self.session = nil;
        }else {
            self.session = session;
        }
        [self refresh];
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.session){
        return [self getBestToken].claims.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *key = [self getBestToken].claims.allKeys[indexPath.row];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [[[self getBestToken].claims objectForKey:key] description];
    return cell;
}

-(void) refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signInButton.enabled = !self.session;
        self.signOutButton.enabled = self.session != nil;
        [self.tableView reloadData];
        self.title = self.session.username;
    });
}

- (IBAction)signOutTapped:(id)sender {
    [self.auth signOut:^(NSError * _Nullable error) {
        if(!error){
            self.session= nil;
            [self alertWithTitle:@"Info" message:@"Session completed"];
            [self refresh];
        }else {
            [self alertWithTitle:@"Error" message:error.userInfo[@"error"]];
        }
    }];
}

- (nullable AWSCognitoAuthUserSessionToken *) getBestToken {
    return self.session.idToken? self.session.idToken : self.session.accessToken;
}

- (void) alertWithTitle: (NSString *) title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:title
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [alert dismissViewControllerAnimated:NO completion:nil];
                                 }];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    });
}
@end
