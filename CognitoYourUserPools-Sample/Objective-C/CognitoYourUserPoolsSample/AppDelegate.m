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

#import "AppDelegate.h"
#import "UserDetailTableViewController.h"
#import "Constants.h"


@interface AppDelegate ()
@property (nonatomic,strong) AWSTaskCompletionSource<NSNumber *>* rememberDeviceCompletionSource;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //setup logging
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    
    //setup service config
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:nil];
    
    if([@"YOUR_USER_POOL_ID" isEqualToString:CognitoIdentityUserPoolId]){
        [[[UIAlertView alloc] initWithTitle:@"Invalid Configuration"
                                    message:@"Please configure user pool constants in Constants.m"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"Ok", nil] show];
    }
    
    //create a pool
    AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:CognitoIdentityUserPoolAppClientId  clientSecret:CognitoIdentityUserPoolAppClientSecret poolId:CognitoIdentityUserPoolId];
    
    [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"UserPool"];
    
    AWSCognitoIdentityUserPool *pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];
    
    self.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    pool.delegate = self;
    
    return YES;
}

//set up password authentication ui to retrieve username and password from the user
-(id<AWSCognitoIdentityPasswordAuthentication>) startPasswordAuthentication {
    
    if(!self.navigationController){
        self.navigationController = [self.storyboard instantiateViewControllerWithIdentifier:@"signinController"];
    }
    if(!self.signInViewController){
        self.signInViewController = self.navigationController.viewControllers[0];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //rewind to login screen
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        //display login screen if it isn't already visibile
        if(!(self.navigationController.isViewLoaded && self.navigationController.view.window))
        {
            [self.window.rootViewController presentViewController:self.navigationController animated:YES completion:nil];
        }
    });
    return self.signInViewController;
}

//set up mfa ui to retrieve mfa code from end user
-(id<AWSCognitoIdentityMultiFactorAuthentication>) startMultiFactorAuthentication {
    if(!self.mfaViewController){
        self.mfaViewController = [MFAViewController new];
        self.mfaViewController.modalPresentationStyle = UIModalPresentationPopover;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //if mfa view isn't already visible, display it
        if (!(self.mfaViewController.isViewLoaded && self.mfaViewController.view.window)) {
            //display mfa as popover on current view controller
            UIViewController *vc = self.window.rootViewController;
            [vc presentViewController:self.mfaViewController animated: YES completion: nil];
            
            //configure popover vc
            UIPopoverPresentationController *presentationController =
            [self.mfaViewController popoverPresentationController];
            presentationController.permittedArrowDirections =
            UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
            presentationController.sourceView = vc.view;
            presentationController.sourceRect = vc.view.bounds;
        }
    });
    return self.mfaViewController;
}

//set up remember device ui
-(id<AWSCognitoIdentityRememberDevice>) startRememberDevice {
    return self;
}

-(void) getRememberDevice: (AWSTaskCompletionSource<NSNumber *> *) rememberDeviceCompletionSource {
    self.rememberDeviceCompletionSource = rememberDeviceCompletionSource;
    
    //Don't do anything fancy here, just display a popup.
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:@"Remember Device"
                                    message:@"Do you want to remember this device?"
                                   delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Yes", nil] show];
    });
}

-(void) didCompleteRememberDeviceStepWithError:(NSError* _Nullable) error {
    [self errorPopup:error];
}

-(void) errorPopup:(NSError *_Nullable) error {
    //Don't do anything fancy here, just display a popup.
    if(error){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:error.userInfo[@"__type"]
                                        message:error.userInfo[@"message"]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"Ok", nil] show];
        });
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            self.rememberDeviceCompletionSource.result = @(NO);
            break;
        case 1:
            self.rememberDeviceCompletionSource.result = @(YES);
            break;
        default:
            break;
    }
    
    self.rememberDeviceCompletionSource = nil;
}

#pragma mark - passwordRequired
-(id<AWSCognitoIdentityNewPasswordRequired>) startNewPasswordRequired {
    if(!self.passwordRequiredViewController){
        self.passwordRequiredViewController = [NewPasswordRequiredViewController new];
        self.passwordRequiredViewController.modalPresentationStyle = UIModalPresentationPopover;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //if new password required view isn't already visible, display it
        if (!(self.passwordRequiredViewController.isViewLoaded && self.passwordRequiredViewController.view.window)) {
            //display mfa as popover on current view controller
            UIViewController *vc = self.window.rootViewController;
            [vc presentViewController:self.passwordRequiredViewController animated: YES completion: nil];
            
            //configure popover vc
            UIPopoverPresentationController *presentationController =
            [self.passwordRequiredViewController popoverPresentationController];
            presentationController.permittedArrowDirections =
            UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
            presentationController.sourceView = vc.view;
            presentationController.sourceRect = vc.view.bounds;
        }
    });
    return self.passwordRequiredViewController;

}

@end

