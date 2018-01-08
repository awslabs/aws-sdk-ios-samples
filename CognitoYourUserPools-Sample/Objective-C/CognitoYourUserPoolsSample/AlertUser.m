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

#import <Foundation/Foundation.h>
#import "AlertUser.h"

@implementation AlertUser


+ (void)alertUser:(nonnull UIViewController *)viewController title:(nullable NSString *)title message:(nullable NSString *)message buttonTitle:(nonnull NSString *)buttonTitle {

    UIAlertController *alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *theButton = [UIAlertAction
                               actionWithTitle:buttonTitle
                               style:UIAlertActionStyleDefault
                               handler:nil];
    
    [alert addAction:theButton];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end

