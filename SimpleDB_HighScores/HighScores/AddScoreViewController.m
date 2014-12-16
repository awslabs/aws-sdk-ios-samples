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

#import "AddScoreViewController.h"
#import "HighScoreList.h"

@implementation AddScoreViewController

-(id)init
{
    self = [super initWithNibName:@"AddScoreViewController" bundle:nil];
    if(self)
    {
        self.title = @"Add New Score";
    }

    return self;
}

-(IBAction)add:(id)sender
{
    [player resignFirstResponder];
    [score resignFirstResponder];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

        HighScore     *highScore     = [[[HighScore alloc] initWithPlayer:[player text] andScore:[[score text] intValue]] autorelease];
        HighScoreList *highScoreList = [[[HighScoreList alloc] init] autorelease];
        
        //Create the domain again, if the domain is present it will not create a duplicate.
        //Code added to make sure if user adds a single score before populating the correctness of the app is maintained
        [highScoreList createHighScoresDomain];
                
        [highScoreList addHighScore:highScore];

        dispatch_async(dispatch_get_main_queue(), ^{

            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            [self dismissModalViewControllerAnimated:YES];
        });
    });
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end