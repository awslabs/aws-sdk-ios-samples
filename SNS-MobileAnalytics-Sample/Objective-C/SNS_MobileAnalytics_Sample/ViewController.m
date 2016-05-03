/*
 * Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UILabel *deviceToken;
@property (strong, nonatomic) IBOutlet UILabel *endpointArn;
@property (strong, nonatomic) IBOutlet UILabel *userAction;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayDeviceInfo {
    NSString *deviceTokenValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"deviceToken"];
    self.deviceToken.text = deviceTokenValue?deviceTokenValue:@"N/A";
    
    NSString *endpointArnValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"endpointArn"];
    self.endpointArn.text = endpointArnValue?endpointArnValue:@"N/A";
}

- (void) displayUserAction:(NSString *)action {
    if (action == nil) {
        self.userAction.text = @"---";
    } else {
        self.userAction.text = [NSString stringWithFormat:@"The user selected [%@]",action];
    }
}

@end
