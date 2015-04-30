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

#import "Constants.h"

#pragma mark - REQUIRED: Amazon Cognito Configuration
#warning To run this sample correctly, you must set the following constants.
AWSRegionType const CognitoRegionType = AWSRegionUnknown; // e.g. AWSRegionUSEast1
NSString *const CognitoIdentityPoolId = @"YourCognitoIdentityPoolId";

#pragma mark - OPTIONAL: Enable FB Login
/**
 * OPTIONAL: Enable FB Login
 *
 * To enable FB Login
 * 1. Add FB SDK to your project
 * 2. Add FacebookAppID in App plist file
 * 3. Add the appropriate URL handler in project (should match FacebookAppID)
 */

#pragma mark - OPTIONAL: Enable Login with Amazon
/**
 * OPTIONAL: Enable Login with Amazon
 *
 * To enable Login with Amazon
 * 1. Add Login with Amazon SDK to your project
 * 2. Add APIKey in App plist file
 * 3. Add the appropriate URL handler in project (of style amzn-BUNDLE_ID)
 */

#pragma mark - OPTIONAL: Enable Google Login
/**
 * OPTIONAL: Enable Google Login
 *
 * To enable Google Login
 * 1. Add Google SDK to your project
 * 2. Add the client ID generated in the Google console below
 * 3. Add the appropriate URL handler in project (Should be the same as BUNDLE_ID)
 */
NSString *const GoogleClientID = @"GoogleClientID";

#pragma mark - OPTIONAL: Enable Twitter/Digits Login
/**
 * OPTIONAL: Enable Twitter/Digits Login
 * 
 * To enable Twitter Login
 * 1. Add Fabric/TwitterKit to your project
 * 2. Add your API keys and Consumer secret
 *    If using Fabric, the Fabric App will walk you through this
 */

#pragma mark - OPTIONAL: Enable Developer Authentication Login
/**
 * OPTIONAL: Enable Developer Authentication Login
 *
 * This sample uses the Java-based Cognito Authentication backend
 * To enable Dev Auth Login
 * 1. Set the values for the constants below to match the running instance
 *    of the example developer authentication backend
 */
// This is the default value, if you modified your backend configuration
// update this value as appropriate
NSString *const DeveloperAuthAppName = @"awscognitodeveloperauthenticationsample";
// Update this value to reflect where your backend is deployed
// !!!!!!!!!!!!!!!!!!!
// Make sure to enable HTTPS for your end point before deploying your
// app to production.
// !!!!!!!!!!!!!!!!!!!
NSString *const DeveloperAuthEndpoint = @"http://YOUR-AUTH-ENDPOINT";
// Set to the provider name you configured in the Cognito console.
NSString *const DeveloperAuthProviderName = @"PROVIDER_NAME";


/*******************************************
 * DO NOT CHANGE THE VALUES BELOW HERE
 */
NSString *const DeviceTokenKey = @"DeviceToken";
NSString *const CognitoDeviceTokenKey = @"CognitoDeviceToken";
NSString *const CognitoPushNotification = @"CognitoPushNotification";
NSString *const GoogleClientScope = @"https://www.googleapis.com/auth/userinfo.profile";
NSString *const GoogleOIDCScope = @"openid";
