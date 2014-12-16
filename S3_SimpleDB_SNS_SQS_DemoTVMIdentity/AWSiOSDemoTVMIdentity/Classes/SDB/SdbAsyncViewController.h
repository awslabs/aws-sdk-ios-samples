/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
#import "SdbRequestDelegate.h"
#import "AmazonClientManager.h"

@interface SdbAsyncViewController:UIViewController {
    SdbRequestDelegate           *sdbDelegate;
    NSTimer                      *timer;
    int                          counter;
    NSString                     *domainName;

    SimpleDBSelectRequest        *selectRequest;
    SimpleDBPutAttributesRequest *putAttributesRequest;
}

@property (nonatomic, retain) IBOutlet UILabel *bytesIn;
@property (nonatomic, retain) IBOutlet UILabel *bytesOut;

-(IBAction)start:(id)sender;
-(IBAction)stop:(id)sender;

-(void)perform;

-(void)createDomain;
-(void)putAttributes;
-(void)selectAttributes;

@end
