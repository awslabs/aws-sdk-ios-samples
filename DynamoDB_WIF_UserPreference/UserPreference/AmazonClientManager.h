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

#import "Constants.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>
#import <FacebookSDK/FacebookSDK.h>


#if GOOGLE_LOGIN
#if AMZN_LOGIN
// Amazon and Google
@interface AmazonClientManager:NSObject<GPPSignInDelegate,AIAuthenticationDelegate> {}
#else
// Just Google
@interface AmazonClientManager:NSObject<GPPSignInDelegate> {}
#endif
#elif AMZN_LOGIN
// Just Amazon
@interface AmazonClientManager:NSObject<AIAuthenticationDelegate> {}
#else
// Neither Amazon nor Google
@interface AmazonClientManager:NSObject {}
#endif

#if FB_LOGIN
@property (retain, nonatomic) FBSession *session;
-(void)reloadFBSession;
-(void)FBLogin;
-(void)FBLogout;
#endif

#if GOOGLE_LOGIN
-(void)reloadGSession;
-(void)initGPlusLogin;
-(void)GoogleLogout;
#endif

#if AMZN_LOGIN
-(void)AMZNLogin;
-(void)AMZNLogout;
#endif

@property (retain, nonatomic) UIViewController *viewController;

+(AmazonClientManager *)sharedInstance;


+(AmazonDynamoDBClient *)ddb;
+(BOOL)hasEmbeddedCredentials;
-(BOOL)isLoggedIn;
-(void)wipeAllCredentials;
+ (void)wipeCredentialsOnAuthError:(NSError *)error;

@end
