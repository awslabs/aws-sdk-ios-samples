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

import UIKit
import AWSCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //
        // Set up Cognito
        //
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: AwsRegion, identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(region: AwsRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        return true
    }

}

