/*
 * Copyright 2015 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

import Foundation
import AWSCore

@objc class Constants : NSObject {

    // MARK: Required: Amazon Cognito Configuration

    static let COGNITO_REGIONTYPE = AWSRegionType.Unknown // e.g. AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "YourCognitoIdentityPoolId"

    // MARK: Optional: Enable Developer Authentication

    //KeyChain Constants
    static let BYOI_PROVIDER = "BYOI"

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
    static let DEVELOPER_AUTH_APP_NAME = "awscognitodeveloperauthenticationsample"
    // Update this value to reflect where your backend is deployed
    // !!!!!!!!!!!!!!!!!!!
    // Make sure to enable HTTPS for your end point before deploying your
    // app to production.
    // !!!!!!!!!!!!!!!!!!!
    static let DEVELOPER_AUTH_ENDPOINT = "http://YourEndpoint/"
    // Set to the provider name you configured in the Cognito console.
    static let DEVELOPER_AUTH_PROVIDER_NAME = "YourAuthProviderName"

    /*******************************************
     * DO NOT CHANGE THE VALUES BELOW HERE
     */

    static let DEVICE_TOKEN_KEY = "DeviceToken"
    static let COGNITO_DEVICE_TOKEN_KEY = "CognitoDeviceToken"
    static let COGNITO_PUSH_NOTIF = "CognitoPushNotification"
}