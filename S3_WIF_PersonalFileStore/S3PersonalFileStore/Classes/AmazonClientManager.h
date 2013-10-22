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

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import <AWSSecurityTokenService/AWSSecurityTokenService.h>
#import "Constants.h"


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

@property (retain, nonatomic) UIViewController *viewController;

#if FB_LOGIN
@property (retain, nonatomic) FBSession *session;

-(void)reloadFBSession;
-(void)FBLogin;
#endif 

#if GOOGLE_LOGIN
-(void)reloadGSession;
-(void)initGPlusLogin;
#endif

#if AMZN_LOGIN
-(void)AMZNLogin;
#endif

+(AmazonClientManager *)sharedInstance;

-(AmazonS3Client *)s3;

-(bool)isLoggedIn;
-(bool)hasCredentials;
-(void)wipeAllCredentials;

@end
