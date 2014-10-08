/*
 * Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "DisplayImageController.h"
#import "Constants.h"
#import "SecondViewController.h"


@interface DisplayImageController ()

@end

@implementation DisplayImageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *downloadingFilePath = nil;
    if(self.fileIndex == 101){
        downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName1];
    }
    else if(self.fileIndex == 102){
        downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName2];
    }
    else if(self.fileIndex == 103){
        downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:LocalFileName3];
    }
    self.myUIImageView.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    
     [self dismissViewControllerAnimated:YES completion:nil];
    
}
@end
