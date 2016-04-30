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
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //setup logging
    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
    
    //setup service config
    AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:nil];
    
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
@end
