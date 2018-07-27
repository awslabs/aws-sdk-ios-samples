/*
 * Copyright 2010-2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

/*
 * Copyright 2016 BJSS, Inc. or its affiliates. All Rights Reserved.
 *
 * Created by Andrea Scuderi on 08/09/2016.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  https://github.com/bjss/aws-sdk-ios-samples/blob/master/LICENSE
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "Constants.h"

@class AWSCognitoCredentialsProvider;
@class AWSCognito;
@class AWSTask;

#if GOOGLE_LOGIN
#if AMZN_LOGIN
// Amazon and Google
@interface AmazonClientManager:NSObject<UIAlertViewDelegate,UIActionSheetDelegate,GPPSignInDelegate,AIAuthenticationDelegate> {}
#else
// Just Google
@interface AmazonClientManager:NSObject<UIAlertViewDelegate,UIActionSheetDelegate,GPPSignInDelegate> {}
#endif
#elif AMZN_LOGIN
// Just Amazon
@interface AmazonClientManager:NSObject<UIAlertViewDelegate,UIActionSheetDelegate,AIAuthenticationDelegate> {}
#else
// Neither Amazon nor Google
@interface AmazonClientManager:NSObject<UIAlertViewDelegate,UIActionSheetDelegate> {}
#endif

- (BOOL)isConfigured;
- (BOOL)isLoggedIn;
- (void)logoutWithCompletionHandler:(AWSContinuationBlock)completionHandler;
- (void)loginFromView:(UIViewController *)theViewController withCompletionHandler:(AWSContinuationBlock)completionHandler;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(nullable NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)resumeSessionWithCompletionHandler:(AWSContinuationBlock)completionHandler;

+ (AmazonClientManager *)sharedInstance;

@end

