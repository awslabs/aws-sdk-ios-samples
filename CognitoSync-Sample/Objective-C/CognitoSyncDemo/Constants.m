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
NSString *const DeveloperAuthEndpoint = @"http://YourEndpoint/";
// Set to the provider name you configured in the Cognito console.
NSString *const DeveloperAuthProviderName = @"YourAuthProviderName";


/*******************************************
 * DO NOT CHANGE THE VALUES BELOW HERE
 */
NSString *const DeviceTokenKey = @"DeviceToken";
NSString *const CognitoDeviceTokenKey = @"CognitoDeviceToken";
NSString *const CognitoPushNotification = @"CognitoPushNotification";
