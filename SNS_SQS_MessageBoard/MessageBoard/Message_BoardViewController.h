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


#import "MessageBoard.h"

// Main View
@interface Message_BoardViewController:UIViewController {
    MessageBoard         *messageBoard;

    IBOutlet UITextField *message;
    IBOutlet UITextField *email;
    IBOutlet UITextField *sms;

    bool                 seenQueueMessage;
}

-(IBAction)subscribeEmail:(id)sender;
-(IBAction)subscribeSMS:(id)sender;
-(IBAction)viewMembers:(id)sender;
-(IBAction)viewQueue:(id)sender;
-(IBAction)post:(id)sender;

-(void)animateTextField:(UITextField *)textField up:(BOOL)moveUp;


@end
