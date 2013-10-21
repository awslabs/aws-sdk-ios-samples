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

#import "AmazonClientManager.h"
#import <AWSRuntime/AWSRuntime.h>
#import "AmazonKeyChainWrapper.h"
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>

static AmazonS3Client                    *_s3  = nil;
static AmazonWIFCredentialsProvider      *_wif = nil;

@implementation AmazonClientManager

@synthesize viewController=_viewController;

#if FB_LOGIN
@synthesize session=_session;
#endif

#if GOOGLE_LOGIN
static GTMOAuth2Authentication  *_auth;
#endif

+ (AmazonClientManager *)sharedInstance
{
    static AmazonClientManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AmazonClientManager alloc] init];
    });
    return sharedInstance;
}



-(AmazonS3Client *)s3
{
    return _s3;
}

-(bool)hasCredentials
{
    return TRUE;
}

-(bool)isLoggedIn
{
    return ( [AmazonKeyChainWrapper username] != nil && _wif != nil);
}

-(void)initClients
{
    if (_wif != nil) {
        [_s3 release];
        _s3  = [[AmazonS3Client alloc] initWithCredentialsProvider:_wif];
    }
}

-(void)wipeAllCredentials
{
    @synchronized(self)
    {
        [_s3 release];
        _s3  = nil;
    }
}

#if FB_LOGIN
#pragma mark - Facebook

-(void)reloadFBSession
{
    if (!self.session.isOpen) {
        // create a fresh session object
        self.session = [[[FBSession alloc] init] autorelease];
        
        // if we don't have a cached token, a call to open here would cause UX for login to
        // occur; we don't want that to happen unless the user clicks the login button, and so
        // we check here to make sure we have a token before calling open
        if (self.session.state == FBSessionStateCreatedTokenLoaded) {
            
            // even though we had a cached token, we need to login to make the session usable
            [self.session openWithCompletionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                if (error != nil) {
                    [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
                }
            }];
        }
    }
}


-(void)CompleteFBLogin
{
    _wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:FB_ROLE_ARN
                                          andWebIdentityToken:self.session.accessTokenData.accessToken
                                                 fromProvider:@"graph.facebook.com"];
    
    // if we have an id, we are logged in
    if (_wif.subjectFromWIF != nil) {
        NSLog(@"IDP id: %@", _wif.subjectFromWIF);
        [AmazonKeyChainWrapper storeUsername:_wif.subjectFromWIF];
        [self initClients];
        [self.viewController dismissModalViewControllerAnimated:NO];
    }
    else {
        [[Constants errorAlert:@"Unable to assume role, please check logs for error"] show];
    }
}

-(void)FBLogin
{
    // session already open, exit
    if (self.session.isOpen) {
        [self CompleteFBLogin];
        return;
    }
    
    if (self.session.state != FBSessionStateCreated) {
        // Create a new, logged out session.
        self.session = [[[FBSession alloc] init] autorelease];
    }
    
    [self.session openWithCompletionHandler:^(FBSession *session,
                                              FBSessionState status,
                                              NSError *error) {
        if (error != nil) {
            [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with FB: %@", error.description]] show];
        }
        else {
            [self CompleteFBLogin];
        }
    }];
    
}
#endif

#if GOOGLE_LOGIN
#pragma mark - Google
- (void)initGPlusLogin
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.delegate = self;
    signIn.clientID = GOOGLE_CLIENT_ID;
    signIn.scopes = [NSArray arrayWithObjects:GOOGLE_CLIENT_SCOPE, GOOGLE_OPENID_SCOPE, nil];
}

- (void)reloadGSession
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GOOGLE_CLIENT_SCOPE]];
    
    [_auth authorizeRequest:request
                     completionHandler:^(NSError *error) {
                         if (error == nil) {
                             [[AmazonClientManager sharedInstance] CompleteGLogin];
                         }
                     }];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    _auth = [auth retain];
    
    if (error != nil) {
        [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with Google: %@", error.description]] show];
    }
    else {
        if (_auth.accessToken == nil) {
            [self reloadGSession];
        }
        else {
            [self CompleteGLogin];
        }
    }
}

-(void)CompleteGLogin
{
    NSString *idToken = [_auth.parameters objectForKey:@"id_token"];
    
    _wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:GOOGLE_ROLE_ARN
                                          andWebIdentityToken:idToken
                                                 fromProvider:nil];
    
    // if we have an id, we are logged in
    if (_wif.subjectFromWIF != nil) {
        NSLog(@"IDP id: %@", _wif.subjectFromWIF);
        [AmazonKeyChainWrapper storeUsername:_wif.subjectFromWIF];
        [self initClients];
        [self.viewController dismissModalViewControllerAnimated:NO];
    }
    else {
        [[Constants errorAlert:@"Unable to assume role, please check logs for error"] show];
    }
}
#endif

#if AMZN_LOGIN
#pragma mark - Login With Amazon


-(void)AMZNLogin
{
    [AIMobileLib authorizeUserForScopes:[NSArray arrayWithObject:@"profile"] delegate:self];
}

- (void) requestDidSucceed:(APIResult*) apiResult {
    if (apiResult.api == kAPIAuthorizeUser) {
        [AIMobileLib getAccessTokenForScopes:[NSArray arrayWithObject:@"profile"] withOverrideParams:nil delegate:self];
    }
    else if (apiResult.api == kAPIGetAccessToken) {
        NSString *token = (NSString *)apiResult.result;
        NSLog(@"%@", token);
        
        _wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:AMZN_ROLE_ARN
                                              andWebIdentityToken:token
                                                     fromProvider:@"www.amazon.com"];
        
        // if we have an id, we are logged in
        if (_wif.subjectFromWIF != nil) {
            NSLog(@"IDP id: %@", _wif.subjectFromWIF);
            [AmazonKeyChainWrapper storeUsername:_wif.subjectFromWIF];
            [self initClients];
            [self.viewController dismissModalViewControllerAnimated:NO];
        }
        else {
            [[Constants errorAlert:@"Unable to assume role, please check logs for error"] show];
        }
    }
}

- (void) requestDidFail:(APIError*) errorResponse {
    [[Constants errorAlert:[NSString stringWithFormat:@"Error logging in with Amazon: %@", errorResponse.error.message]] show];
}


#endif



@end
