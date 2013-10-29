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

#import "LoginViewController.h"
#import "AmazonClientManager.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.

#if FB_LOGIN
    [[AmazonClientManager sharedInstance] reloadFBSession];
#endif

    
#if GOOGLE_LOGIN
    [[AmazonClientManager sharedInstance] initGPlusLogin];
    GPPSignInButton *signInButton = [[[GPPSignInButton alloc] initWithFrame:CGRectMake(20, 122, 280, 44)] autorelease];
    [self.view addSubview:signInButton];
#else
    UIButton *signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signInButton.frame = CGRectMake(20, 122, 280, 44);
    [signInButton setTitle:@"Google"
             forState:(UIControlState)UIControlStateNormal];
    [signInButton addTarget:self
                action:@selector(Glogin:)
      forControlEvents:(UIControlEvents)UIControlEventTouchDown];
    [signInButton setBackgroundColor:[UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0]];
    [self.view addSubview:signInButton];
#endif

    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated
{
    [AmazonClientManager sharedInstance].viewController = self;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [AmazonClientManager sharedInstance].viewController = nil;
    [super viewWillDisappear:animated];
}

-(IBAction)FBlogin:(id)sender
{
#if FB_LOGIN
    [self dismissModalViewControllerAnimated:YES];
    [[AmazonClientManager sharedInstance] FBLogin];
#else
    [[[[UIAlertView alloc] initWithTitle:@"Not Enabled" message:IDP_NOT_ENABLED_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
#endif
}

-(IBAction)Glogin:(id)sender
{
    [[[[UIAlertView alloc] initWithTitle:@"Not Enabled" message:IDP_NOT_ENABLED_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
}

-(IBAction)AMZNlogin:(id)sender
{
#if AMZN_LOGIN
    [self dismissModalViewControllerAnimated:YES];
    [[AmazonClientManager sharedInstance] AMZNLogin];
#else
    [[[[UIAlertView alloc] initWithTitle:@"Not Enabled" message:IDP_NOT_ENABLED_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
#endif
}

-(void)dealloc
{
    [super dealloc];
}

@end
