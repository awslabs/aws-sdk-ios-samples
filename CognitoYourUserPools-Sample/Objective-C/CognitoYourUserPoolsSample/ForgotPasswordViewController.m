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

#import "ForgotPasswordViewController.h"
#import "AWSCognitoIdentityProvider.h"
#import "ConfirmForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@property (nonatomic, strong) AWSCognitoIdentityUser * user;
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([@"confirmForgotPasswordSegue" isEqualToString:segue.identifier]){
        ConfirmForgotPasswordViewController * confirmForgot = segue.destinationViewController;
        confirmForgot.user = self.user;
    }
}

- (IBAction)forgotPassword:(id)sender {
    self.user = [self.pool getUser:self.username.text];
    [[self.user forgotPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [[[UIAlertView alloc] initWithTitle:task.error.userInfo[@"__type"]
                                            message:task.error.userInfo[@"message"]
                                           delegate:nil
                                  cancelButtonTitle:@"Ok"
                                  otherButtonTitles:nil] show];
            }else {
                [self performSegueWithIdentifier:@"confirmForgotPasswordSegue" sender:sender];
            }
        });
        return nil;
    }];
}

@end
