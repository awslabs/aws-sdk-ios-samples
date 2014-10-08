#SNS Mobile Push and Mobile Analytics Sample

This sample demonstrates how you would track user engagement for the mobile push notifications using [Amazon Cognito](http://aws.amazon.com/cognito/), [Amazon SNS Mobile Push](http://aws.amazon.com/sns/), and [Amazon Mobile Analytics](http://aws.amazon.com/mobileanalytics/).

##Requirements

* Xcode 5 and later
* iOS 7 and later
* Before moving forward, follow [Getting Started with Apple Push Notification Service](http://docs.aws.amazon.com/sns/latest/dg/mobile-push-apns.html) and [Using Amazon SNS Mobile Push](http://docs.aws.amazon.com/sns/latest/dg/mobile-push-send.html) and configure Amazon SNS Mobile Push properly.

##Setting up CocoaPods

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods by running the command:

		sudo gem install cocoapods

1. In your project directory, create a text file named **Podfile** and add the following lines:

        source 'https://github.com/CocoaPods/Specs.git'
        
        pod "AWSiOSSDKv2"
        
1. Then run the following command:
	
		pod install

##Getting Started with Swift

1. Create an Objective-C bridging header file.
1. Import the service headers in the bridging header.

		#import "AWSCore.h"
		#import "SNS.h"

1. Point **SWIFT_OBJC_BRIDGING_HEADER** to the bridging header by going to **Your Target** => **Build Settings** => **SWIFT_OBJC_BRIDGING_HEADER**.

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `AccountID`, `PoolID`, and `RoleUnauth` constants. Make sure the [role](https://console.aws.amazon.com/iam/home?region=us-east-1#roles) has appropriate permissions for Amazon SNS Mobile Push and Amazon Mobile Analytics. Use Amazon Mobile Analytics to create an app, and obtain the `AppId` constant.

1. Open `AppDelegate.swift` and update the following lines with the appropriate constants:

        let cognitoAccountId = "Your-AccountID"
        let cognitoIdentityPoolId = "Your-PoolID"
        let cognitoUnauthRoleArn = "Your-RoleUnauth"
        let snsPlatformApplicationArn = "Your-Platform-Applicatoin-ARN"
        let mobileAnalyticsAppId = "Your-MobileAnalytics-AppId"

1. Create a default service configuration by adding the following code snippet in the `@optional func application(_ application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool` application delegate method.

        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            accountId: cognitoAccountId,
            identityPoolId: cognitoIdentityPoolId,
            unauthRoleArn: cognitoUnauthRoleArn,
            authRoleArn: cognitoAuthRoleArn)
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1,
            credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)

##Set up interactive push notifications

You can set up a notification category in `- application:didFinishLaunchingWithOptions:` using the following code:

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
        messageCategory.setActions([ignoreAction], forContext: UIUserNotificationActionContext.Default)

        let types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
        let notificationSettings = UIUserNotificationSettings(forTypes: types, categories: NSSet(object: messageCategory))

        UIApplication.sharedApplication().registerForRemoteNotifications()
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        ...

        return true
    }

##Set up the Amazon Cognito credentials provider

You can set up the Cognito credentials provider in `- application:didFinishLaunchingWithOptions:` as follows:

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        ...
        
        // Sets up the AWS Mobile SDK for iOS
        let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
            AWSRegionType.USEast1,
            accountId: "YOUR-ACCOUNT-ID",
            identityPoolId: "YOUR-IDENTITY-POOL-ID",
            unauthRoleArn: "YOUR-UNAUTH-ROLE-ARN",
            authRoleArn: "YOUR-AUTH-ROLE-ARN")
        let defaultServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)

        return true
    }

Once the default credentials provider is registered, you can start using default service clients anywhere in your app.

##Register tokens for push notifications

When iOS generates `deviceToken`, which is necessary for Amazon SNS Mobile Push, `- application:didRegisterForRemoteNotificationsWithDeviceToken:` is called. You can create an Amazon SNS platform application endpoint using the `deviceToken` as follows:

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenString = "\(deviceToken)"
            .stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"<>"))
            .stringByReplacingOccurrencesOfString(" ", withString: "")
        println("deviceTokenString: \(deviceTokenString)")

        let sns = AWSSNS.defaultSNS()
        let request = AWSSNSCreatePlatformEndpointInput()
        request.token = deviceTokenString
        request.platformApplicationArn = "YOUR-PLATFORM-APPLICATION-ARN"
        sns.createPlatformEndpoint(request).continueWithBlock { (task: BFTask!) -> AnyObject! in
            if task.error != nil {
                println("Error: \(task.error)")
            } else {
                let createEndpointResponse = task.result as AWSSNSCreateEndpointResponse
                println("endpointArn: \(createEndpointResponse.endpointArn)")
            }

            return nil
        }
    }

You can use this generated **Endpoint ARN** to push notifications using Amazon SNS Mobile Push.

##Receive push notifications callback

When the iOS device receives the interactive push notification, and the user makes an action, `- application:handleActionWithIdentifier:forLocalNotification:completionHandler:` is called. By looking at `identifier`, you can find out which option the user selected in the interactive push notification.

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        if identifier == "READ_IDENTIFIER" {
            println("User selected 'Read'")

        } else if identifier == "DELETE_IDENTIFIER" {
            println("User selected 'Delete'")
        }

        completionHandler()
    }

##Track user actions using Amazon Mobile Analytics

You can track user actions by using the **Custom Events** feature of Amazon Mobile Analytics.

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        let mobileAnalytics = AWSMobileAnalytics(forAppId: "YOUR-APPID")
        let eventClient = mobileAnalytics.eventClient
        let pushNotificationEvent = eventClient.createEventWithEventType("PushNotificationEvent")

        if identifier == "READ_IDENTIFIER" {
            pushNotificationEvent.addAttribute("Read", forKey: "Action")
            println("User selected 'Read'")

        } else if identifier == "DELETE_IDENTIFIER" {
            pushNotificationEvent.addAttribute("Deleted", forKey: "Action")
            println("User selected 'Delete'")
        } else {
            pushNotificationEvent.addAttribute("Undefined", forKey: "Action")
        }

        eventClient.recordEvent(pushNotificationEvent)

        completionHandler()
    }

##Push notifications and track user actions

Now you are ready to push notifications to your device. Once you run the sample app, you can find your device endpoint in your app on the [AWS Management Console](http://aws.amazon.com/console/) under SNS. Select your device and click **Publish**. Select **Use platform specific JSON message dictionaries** option and copy and paste the following message, then click **Publish Message**.

    {"APNS":"{\"aps\":{\"alert\":\"MESSAGE\",\"category\":\"MESSAGE_CATEGORY\"} }"}

If your app is in the background, you receive an interactive notification. When you select *Read* or *Delete*, it is recorded by Amazon Mobile Analytics. You can see the metrics on the AWS Management Console under Mobile Analytics.