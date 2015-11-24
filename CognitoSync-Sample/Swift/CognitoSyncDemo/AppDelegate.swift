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

import UIKit
import TwitterKit
import Fabric
import DigitsKit
import AWSCognito
import AWSCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return AmazonClientManager.sharedInstance.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if AWSCognito.cognitoDeviceId() != nil {
            let canRegisterApp : UIApplication? = application
            canRegisterApp?.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Alert, categories: nil))
        }
        
        Fabric.with([Twitter.self(), Digits.self()])

        return AmazonClientManager.sharedInstance.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(deviceToken, forKey: Constants.DEVICE_TOKEN_KEY)
        userDefaults.synchronize()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Error in registering for remote notifications: " + error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.COGNITO_PUSH_NOTIF, object: userInfo)
    }

}

