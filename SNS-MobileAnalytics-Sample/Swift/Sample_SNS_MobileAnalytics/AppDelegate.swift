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

let cognitoAccountId = "Your-AccountID"
let cognitoIdentityPoolId = "Your-PoolID"
let cognitoUnauthRoleArn = "Your-RoleUnauth"
let snsPlatformApplicationArn = "Your-Platform-Applicatoin-ARN"
let mobileAnalyticsAppId = "Your-MobileAnalytics-AppId"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configures the appearance
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent

        // Sets up Mobile Push Notification
        let readAction = UIMutableUserNotificationAction()
        readAction.identifier = "READ_IDENTIFIER"
        readAction.title = "Read"
        readAction.activationMode = UIUserNotificationActivationMode.Foreground
        readAction.destructive = false
        readAction.authenticationRequired = true

        let deleteAction = UIMutableUserNotificationAction()
        deleteAction.identifier = "DELETE_IDENTIFIER"
        deleteAction.title = "Delete"
        deleteAction.activationMode = UIUserNotificationActivationMode.Foreground
        deleteAction.destructive = true
        deleteAction.authenticationRequired = true

        let ignoreAction = UIMutableUserNotificationAction()
        ignoreAction.identifier = "IGNORE_IDENTIFIER"
        ignoreAction.title = "Ignore"
        ignoreAction.activationMode = UIUserNotificationActivationMode.Foreground
        ignoreAction.destructive = false
        ignoreAction.authenticationRequired = false

        let messageCategory = UIMutableUserNotificationCategory()
        messageCategory.identifier = "MESSAGE_CATEGORY"
        messageCategory.setActions([readAction, deleteAction], forContext: UIUserNotificationActionContext.Minimal)
        messageCategory.setActions([readAction, deleteAction, ignoreAction], forContext: UIUserNotificationActionContext.Default)

        let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: messageCategory))

        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        // Sets up the AWS Mobile SDK for iOS
        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            accountId: cognitoAccountId,
            identityPoolId: cognitoIdentityPoolId,
            unauthRoleArn: cognitoUnauthRoleArn,
            authRoleArn: nil)
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)

        return true
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = "\(deviceToken)"
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>"))
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        println("deviceTokenString: \(deviceTokenString)")
        NSUserDefaults.standardUserDefaults().setObject(deviceTokenString, forKey: "deviceToken")
        mainViewController()?.displayDeviceInfo()

        let sns = AWSSNS.defaultSNS()
        let request = AWSSNSCreatePlatformEndpointInput()
        request.token = deviceTokenString
        request.platformApplicationArn = snsPlatformApplicationArn
        sns.createPlatformEndpoint(request).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                let createEndpointResponse = task.result as AWSSNSCreateEndpointResponse
                println("endpointArn: \(createEndpointResponse.endpointArn)")
                NSUserDefaults.standardUserDefaults().setObject(createEndpointResponse.endpointArn, forKey: "endpointArn")
                self.mainViewController()?.displayDeviceInfo()
            }

            return nil
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("Failed to register with error: \(error)")
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("userInfo: \(userInfo)")
    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        let mobileAnalytics = AWSMobileAnalytics(forAppId: mobileAnalyticsAppId)
        let eventClient = mobileAnalytics.eventClient
        let pushNotificationEvent = eventClient.createEventWithEventType("PushNotificationEvent")

        var action = "Undefined"
        if identifier == "READ_IDENTIFIER" {
            action = "Read"
            println("User selected 'Read'")
        } else if identifier == "DELETE_IDENTIFIER" {
            action = "Deleted"
            println("User selected 'Delete'")
        } else {
            action = "Undefined"
        }

        pushNotificationEvent.addAttribute(action, forKey: "Action")
        eventClient.recordEvent(pushNotificationEvent)

        mainViewController()?.displayUserAction(action)

        completionHandler()
    }

    func mainViewController() -> MainViewController? {
        let rootViewController = self.window!.rootViewController
        if rootViewController?.childViewControllers.first is MainViewController {
            return rootViewController?.childViewControllers.first as MainViewController?
        }
        
        return nil
    }
}

