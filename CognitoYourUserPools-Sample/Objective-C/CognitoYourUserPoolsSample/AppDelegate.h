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

#import <UIKit/UIKit.h>
#import "AWSCognitoIdentityProvider.h"
#import "MFAViewController.h"
#import "SignInViewController.h"
#import "NewPasswordRequiredViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, AWSCognitoIdentityInteractiveAuthenticationDelegate, AWSCognitoIdentityRememberDevice, UIAlertViewDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *storyboard;
@property(nonatomic,strong) UINavigationController *navigationController;
@property(nonatomic,strong) SignInViewController* signInViewController;
@property(nonatomic,strong) MFAViewController* mfaViewController;
@property(nonatomic,strong) NewPasswordRequiredViewController* passwordRequiredViewController;
@end

