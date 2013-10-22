/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <UIKit/UIKit.h>


@interface ObjectViewController:UIViewController {
    NSString         *objectName;
    NSString         *bucket;

    IBOutlet UILabel *objectNameLabel;
    IBOutlet UILabel *objectDataLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *objectNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *objectDataLabel;

@property (nonatomic, retain) NSString         *objectName;
@property (nonatomic, retain) NSString         *bucket;

-(IBAction)done:(id)sender;

@end
