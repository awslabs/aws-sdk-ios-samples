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

#import "MFAViewController.h"

@interface MFAViewController ()
@property (weak, nonatomic) IBOutlet UITextField *confirmationCode;
@property (weak, nonatomic) IBOutlet UILabel *sentTo;
@property (strong, nonatomic) NSString *destination;
@property (nonatomic,strong) AWSTaskCompletionSource<NSString *>* mfaCodeCompletionSource;
@end

@implementation MFAViewController

- (void) viewWillAppear:(BOOL)animated {
    self.sentTo.text = [NSString stringWithFormat:@"Code sent to: %@", self.destination];
    self.confirmationCode.text = nil;
}

- (IBAction)signIn:(id)sender {
    self.mfaCodeCompletionSource.result = self.confirmationCode.text;
}

-(void) getMultiFactorAuthenticationCode: (AWSCognitoIdentityMultifactorAuthenticationInput *)authenticationInput mfaCodeCompletionSource: (AWSTaskCompletionSource<NSString *> *) mfaCodeCompletionSource {
    self.mfaCodeCompletionSource = mfaCodeCompletionSource;
    self.destination = authenticationInput.destination;
}


-(void) didCompleteMultifactorAuthenticationStepWithError:(NSError*) error {
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
@end
