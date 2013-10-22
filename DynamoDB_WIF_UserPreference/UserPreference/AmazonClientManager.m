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

#import "AmazonClientManager.h"
#import <AWSRuntime/AWSRuntime.h>
#import "AmazonKeyChainWrapper.h"
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>


static AmazonDynamoDBClient *ddb = nil;
static AmazonWIFCredentialsProvider *wif = nil;

@implementation AmazonClientManager

@synthesize viewController=_viewController;

#if FB_LOGIN
@synthesize session = _session;
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
        if ([AmazonClientManager hasEmbeddedCredentials]) {
            [AmazonClientManager initClientsWithEmbeddedCredentials];
        }
    });
    return sharedInstance;
}

+(AmazonDynamoDBClient *)ddb
{
    return ddb;
}

-(BOOL)isLoggedIn
{
    if ([AmazonClientManager hasEmbeddedCredentials]) {
        return YES;
    }
    return ( [AmazonKeyChainWrapper username] != nil && wif != nil);
}


+(BOOL)hasEmbeddedCredentials
{
    return ![ACCESS_KEY_ID isEqualToString:@"CHANGE ME"] && ![SECRET_KEY isEqualToString:@"CHANGE ME"];
}


-(void)initClients
{
    if (wif != nil) {
        [ddb release];
        ddb  = [[AmazonDynamoDBClient alloc] initWithCredentialsProvider:wif];
    }
}

+(void)initClientsWithEmbeddedCredentials
{
    if (ddb == nil) {
        AmazonCredentials *credentials = [[[AmazonCredentials alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY] autorelease];
        [ddb release];
        ddb = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
    }
}

-(void)wipeAllCredentials
{
    @synchronized(self)
    {        
        [ddb release];
        ddb = nil;
#if FB_LOGIN
        [[AmazonClientManager sharedInstance] FBLogout];
#endif
        
#if AMZN_LOGIN
        [[AmazonClientManager sharedInstance] AMZNLogout];
#endif
        
#if GOOGLE_LOGIN
        [[AmazonClientManager sharedInstance] GoogleLogout];
#endif
        [AmazonKeyChainWrapper wipeKeyChain];
    }
}

+ (void)wipeCredentialsOnAuthError:(NSError *)error
{
    id exception = [error.userInfo objectForKey:@"exception"];
    
    if([exception isKindOfClass:[AmazonServiceException class]])
    {
        AmazonServiceException *e = (AmazonServiceException *)exception;
        
        if(
           // STS http://docs.amazonwebservices.com/STS/latest/APIReference/CommonErrors.html
           [e.errorCode isEqualToString:@"IncompleteSignature"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InvalidClientTokenId"]
           || [e.errorCode isEqualToString:@"OptInRequired"]
           || [e.errorCode isEqualToString:@"RequestExpired"]
           || [e.errorCode isEqualToString:@"ServiceUnavailable"]
           
           // DynamoDB http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/ErrorHandling.html#APIErrorTypes
           || [e.errorCode isEqualToString:@"AccessDeniedException"]
           || [e.errorCode isEqualToString:@"IncompleteSignatureException"]
           || [e.errorCode isEqualToString:@"MissingAuthenticationTokenException"]
           || [e.errorCode isEqualToString:@"ValidationException"]
           || [e.errorCode isEqualToString:@"InternalFailure"]
           || [e.errorCode isEqualToString:@"InternalServerError"])
        {
            [[self sharedInstance] wipeAllCredentials];
        }
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
    
    wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:FB_ROLE_ARN
                                          andWebIdentityToken:self.session.accessTokenData.accessToken
                                                 fromProvider:@"graph.facebook.com"];
    
    // if we have an id, we are logged in
    if (wif.subjectFromWIF != nil) {
        NSLog(@"IDP id: %@", wif.subjectFromWIF);
        [AmazonKeyChainWrapper storeUsername:wif.subjectFromWIF];
        
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

-(void)FBLogout
{
    [[FBSession activeSession] close];
}

#endif

#if GOOGLE_LOGIN
#pragma mark - Google
- (void)initGPlusLogin
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.delegate = self;
    signIn.clientID = GOOGLE_CLIENT_ID; 
    signIn.scopes = [NSArray arrayWithObjects:GOOGLE_CLIENT_SCOPE,GOOGLE_OPENID_SCOPE, nil];
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
    
    wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:GOOGLE_ROLE_ARN
                                          andWebIdentityToken:idToken
                                                 fromProvider:nil];
    
    // if we have an id, we are logged in
    if (wif.subjectFromWIF != nil) {
        NSLog(@"IDP id: %@", wif.subjectFromWIF);
        [AmazonKeyChainWrapper storeUsername:wif.subjectFromWIF];
        [self initClients];
        [self.viewController dismissModalViewControllerAnimated:NO];
    }
    else {
        [[Constants errorAlert:@"Unable to assume role, please check logs for error"] show];
    }
}

-(void)GoogleLogout
{
    [[GPPSignIn sharedInstance] signOut];
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
        
        wif = [[AmazonWIFCredentialsProvider alloc] initWithRole:AMZN_ROLE_ARN
                                              andWebIdentityToken:token
                                                     fromProvider:@"www.amazon.com"];
        
        // if we have an id, we are logged in
        if (wif.subjectFromWIF != nil) {
            NSLog(@"IDP id: %@", wif.subjectFromWIF);
            [AmazonKeyChainWrapper storeUsername:wif.subjectFromWIF];
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

- (void)AMZNLogout {
    [AIMobileLib clearAuthorizationState:self];
}



#endif


@end
