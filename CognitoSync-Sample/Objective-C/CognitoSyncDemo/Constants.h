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

#import <Foundation/Foundation.h>
#import <AWSCore/AWSCore.h>

FOUNDATION_EXPORT AWSRegionType const CognitoRegionType;
FOUNDATION_EXPORT NSString *const CognitoIdentityPoolId;

FOUNDATION_EXPORT NSString *const DeviceTokenKey;
FOUNDATION_EXPORT NSString *const CognitoDeviceTokenKey;
FOUNDATION_EXPORT NSString *const CognitoPushNotification;
FOUNDATION_EXPORT NSString *const GoogleClientScope;
FOUNDATION_EXPORT NSString *const GoogleOIDCScope;
FOUNDATION_EXPORT NSString *const GoogleClientID;
FOUNDATION_EXPORT NSString *const DeveloperAuthAppName;
FOUNDATION_EXPORT NSString *const DeveloperAuthEndpoint;
FOUNDATION_EXPORT NSString *const DeveloperAuthProviderName;

#if __has_include(<FBSDKCoreKit/FBSDKCoreKit.h>) && __has_include(<FBSDKLoginKit/FBSDKLoginKit.h>)
#define FB_LOGIN 1
#else
#define FB_LOGIN 0
#endif

#if FB_LOGIN

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#endif

#if __has_include(<LoginWithAmazon/LoginWithAmazon.h>)
#define AMZN_LOGIN 1
#else
#define AMZN_LOGIN 0
#endif

#if AMZN_LOGIN

#import <LoginWithAmazon/LoginWithAmazon.h>

#endif

#if __has_include(<GooglePlus/GooglePlus.h>) && __has_include(<GoogleOpenSource/GoogleOpenSource.h>)
#define GOOGLE_LOGIN 1
#else
#define GOOGLE_LOGIN 0
#endif

#if GOOGLE_LOGIN

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#endif

#if __has_include(<TwitterKit/TwitterKit.h>) && __has_include(<Fabric/Fabric.h>)
#define TWITTER_LOGIN 1
#else 
#define TWITTER_LOGIN 0
#endif

#if TWITTER_LOGIN

#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#endif