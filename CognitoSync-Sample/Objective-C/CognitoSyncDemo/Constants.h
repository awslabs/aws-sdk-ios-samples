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
#import "AWSCore.h"

FOUNDATION_EXPORT AWSRegionType const CognitoRegionType;
FOUNDATION_EXPORT NSString *const CognitoIdentityPoolId;

FOUNDATION_EXPORT NSString *const DeviceTokenKey;
FOUNDATION_EXPORT NSString *const CognitoDeviceTokenKey;
FOUNDATION_EXPORT NSString *const CognitoPushNotification;

/**
 * Enables Developer Authentication Login.
 * This sample uses the Java-based Cognito Authentication backend
 */
#define BYOI_LOGIN                  0

#if BYOI_LOGIN

// This is the default value, if you modified your backend configuration
// update this value as appropriate
#define AppName @"awscognitodeveloperauthenticationsample"
// Update this value to reflect where your backend is deployed
// !!!!!!!!!!!!!!!!!!!
// Make sure to enable HTTPS for your end point before deploying your
// app to production.
// !!!!!!!!!!!!!!!!!!!
#define Endpoint @"http://YOUR-AUTH-ENDPOINT"
// Set to the provider name you configured in the Cognito console.
#define ProviderName @"PROVIDER_NAME"

#endif

/**
 * Enables FB Login.
 * Login with Facebook also requires the following things to be set
 *
 * FacebookAppID in App plist file
 * The appropriate URL handler in project (should match FacebookAppID)
 */
#define FB_LOGIN                    1

#if FB_LOGIN

#import <FacebookSDK/FacebookSDK.h>

#endif

/**
 * Enables Amazon
 * Login with Amazon also requires the following things to be set
 *
 * APIKey in App plist file
 * The appropriate URL handler in project (of style amzn-BUNDLE_ID)
 */
#define AMZN_LOGIN                  1

#if AMZN_LOGIN

#import <LoginWithAmazon/LoginWithAmazon.h>

#endif

/**
 * Enables Google+
 * Google+ login also requires the following things to be set
 *
 * The appropriate URL handler in project (Should be the same as BUNDLE_ID)
 */
#define GOOGLE_LOGIN                0

#if GOOGLE_LOGIN

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

/**
 * Client ID retrieved from Google API console
 */
#define GOOGLE_CLIENT_ID            @""

/**
 * Client scope that will be used with Google+
 */
#define GOOGLE_CLIENT_SCOPE         @"https://www.googleapis.com/auth/userinfo.profile"
#define GOOGLE_OPENID_SCOPE         @"openid"

#endif