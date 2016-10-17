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


#import "NewPasswordRequiredViewController.h"


@interface NewPasswordRequiredViewController ()
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@property (nonatomic,strong) AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails *>* passwordRequiredCompletionSource;
@property (nonatomic,strong) AWSCognitoIdentityNewPasswordRequiredDetails * passwordRequiredDetails;
@end

@implementation NewPasswordRequiredViewController


/**
 Ensure phone number starts with country code i.e. (+1)
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
    if(textField == self.phone){
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\+(|\\d)*$" options:0 error:nil];
        NSString *proposedPhone = [self.phone.text stringByReplacingCharactersInRange:range withString:string];
        if(proposedPhone.length != 0){
            return [regex numberOfMatchesInString:proposedPhone options:NSMatchingAnchored range:NSMakeRange(0, proposedPhone.length)]== 1;
        }
    }
    return YES;
}


-(void) getNewPasswordDetails: (AWSCognitoIdentityNewPasswordRequiredInput *) newPasswordRequiredInput newPasswordRequiredCompletionSource: (AWSTaskCompletionSource<AWSCognitoIdentityNewPasswordRequiredDetails *> *) newPasswordRequiredCompletionSource {
    self.passwordRequiredCompletionSource = newPasswordRequiredCompletionSource;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.phone.text = newPasswordRequiredInput.userAttributes[@"phone_number"];
        self.email.text = newPasswordRequiredInput.userAttributes[@"email"];
    });
}

-(void) didCompleteNewPasswordStepWithError:(NSError* _Nullable) error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(error){
            [[[UIAlertView alloc] initWithTitle:error.userInfo[@"__type"]
                                        message:error.userInfo[@"message"]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Retry", nil] show];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}
- (IBAction)completeProfile:(id)sender {
    NSDictionary<NSString *, NSString *> *userAttributes = @{@"phone_number":self.phone.text, @"email":self.email.text};
    AWSCognitoIdentityNewPasswordRequiredDetails *details = [[AWSCognitoIdentityNewPasswordRequiredDetails alloc] initWithProposedPassword:self.password.text userAttributes:userAttributes];
    self.passwordRequiredCompletionSource.result = details;
}

@end
