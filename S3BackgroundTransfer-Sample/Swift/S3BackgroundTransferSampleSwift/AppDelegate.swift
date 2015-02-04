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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundDownloadSessionCompletionHandler: ()?
    var backgroundUploadSessionCompletionHandler: ()?

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {

        NSLog("[%@ %@]", reflect(self).summary, __FUNCTION__)
        /*
        Store the completion handler.
        */
        if identifier == BackgroundSessionUploadIdentifier {
            self.backgroundUploadSessionCompletionHandler = completionHandler()
        } else if identifier == BackgroundSessionDownloadIdentifier {
            self.backgroundDownloadSessionCompletionHandler = completionHandler()
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let credentialProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            CognitoRegionType,
            identityPoolId: CognitoIdentityPoolId)
        let configuration = AWSServiceConfiguration(
            region: DefaultServiceRegionType,
            credentialsProvider: credentialProvider)

        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(configuration)

        return true
    }
}
