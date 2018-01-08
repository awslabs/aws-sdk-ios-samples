//
// Copyright 2014-2018 Amazon.com,
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

#import "ConfirmForgotPasswordViewController.h"
#import "AlertUser.h"

@interface ConfirmForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *confirmationCode;
@property (weak, nonatomic) IBOutlet UITextField *proposedPassword;

@end

@implementation ConfirmForgotPasswordViewController

- (IBAction)updatePassword:(id)sender {
    //confirm forgot password with input from ui.
    [[self.user confirmForgotPassword:self.confirmationCode.text password:self.proposedPassword.text] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [AlertUser alertUser: self
                                title:task.error.userInfo[@"__type"]
                                message:task.error.userInfo[@"message"]
                                buttonTitle:@"Ok"];
            }else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        });
        return nil;
    }];
}

@end
