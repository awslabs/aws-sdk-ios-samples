//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSMobileClient
import AWSPinpoint
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate,
    UISplitViewControllerDelegate, UINavigationControllerDelegate {
    // MARK: instance properties

    var window: UIWindow?

    var pinpoint: AWSPinpoint!

    var sessionId: String?

    private var analyticsTimer: AnalyticsEventTimer!

    deinit {
        analyticsTimer.cancel()
    }

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sessionId = UUID().uuidString
        registerForPushNotifications()

        // setup views
        setupSplitView()

        // setup logging
        AWSDDLog.sharedInstance.logLevel = .info
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)

        // initialize clients
        initializeMobileClient()
        initializePinpoint(launchOptions: launchOptions)

        return true
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("***********************")
        print("application didRegisterForRemoteNotificationsWithDeviceToken")
        print("deviceToken = \(deviceToken.toHexString())")
    }

    // MARK: AWS Initializers

    private func initializeMobileClient() {
        AWSMobileClient.default().initialize { userState, error in
            if let error = error {
                print("Error initializing AWSMobileClient: \(error.localizedDescription)")
            } else if let userState = userState {
                print("AWSMobileClient initialized. Current userState: \(userState.rawValue)")
            }
        }
    }

    private func initializePinpoint(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let pinpointConfiguration = AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions)
        pinpoint = AWSPinpoint(configuration: pinpointConfiguration)
//        pinpoint.notificationManager.interceptDidRegisterForRemoteNotificationsWithDeviceToken { (token) in
//            print("*** interceptDidRegisterForRemoteNotificationsWithDeviceToken")
//            print("token = \(token)")
//            return nil
//        }
        analyticsTimer = AnalyticsEventTimer(analyticsClient: pinpoint.analyticsClient)
        analyticsTimer.resume()
    }

    // MARK: - Application Lifecycle

    func applicationWillResignActive(_: UIApplication) {
        pinpoint.sessionClient.pauseSession(withTimeoutEnabled: true)
        recordAppLifecycleEvent(type: .appWillResignActive)
    }

    func applicationDidEnterBackground(_: UIApplication) {
        pinpoint.sessionClient.pauseSession(withTimeoutEnabled: true)
        analyticsTimer.suspend()
        recordAppLifecycleEvent(type: .appDidEnterBackground)
    }

    func applicationWillEnterForeground(_: UIApplication) {
        pinpoint.sessionClient.resumeSession()
        recordAppLifecycleEvent(type: .appWillEnterForeground)
    }

    func applicationDidBecomeActive(_: UIApplication) {
        print("------------------------------------")
        print("\(String(describing: self)) applicationDidBecomeActive............")
        print("isRegisteredForRemoteNotifications = \(UIApplication.shared.isRegisteredForRemoteNotifications)")
        analyticsTimer.resume()
        pinpoint.sessionClient.startSession()

        updateEndpoint()
        recordAppLifecycleEvent(type: .appDidBecomeActive)
    }

    func applicationWillTerminate(_: UIApplication) {
        sessionId = nil
        pinpoint.sessionClient.stopSession()
        analyticsTimer.cancel()
        recordAppLifecycleEvent(type: .appWillTerminate)
    }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("Error registering for Push Notifications...")
                }
            }
        } else {
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            DispatchQueue.main.async {
                UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            }
        }
    }

    // MARK: Navigation

    func navigationController(_ controller: UINavigationController,
                              willShow viewController: UIViewController,
                              animated _: Bool) {
        let analyticsClient = pinpoint.analyticsClient

        let event = pinpoint.analyticsClient.createEvent(withEventType: "screen.did_show")
        event.addAttribute(String(describing: type(of: viewController)), forKey: "name")
        event.addAttribute(viewController.navigationItem.title ?? "", forKey: "title")

        if let topViewController = controller.topViewController {
            event.addAttribute(String(describing: type(of: topViewController)), forKey: "referrer")
        }

        analyticsClient.record(event)
    }

    // MARK: Helpers

    private func updateEndpoint() {
        let targetingClient = pinpoint.targetingClient
        let endpoint = targetingClient.currentEndpointProfile()

        let user = endpoint.user ?? AWSPinpointEndpointProfileUser()
        user.userId = UUID().uuidString
        endpoint.user = user

        print("=====================")
        print("endpoint.user = \(String(describing: endpoint.user))")
        print("endpoint.endpointId = \(endpoint.endpointId)")
        print("endpoint.channelType = \(String(describing: endpoint.channelType))")
        print("enpoint.address = \(String(describing: endpoint.address))")

        targetingClient.update(endpoint)
        print("Assigned user ID \(user.userId ?? "nil") to endpoint \(endpoint.endpointId)")
    }

    private func recordAppLifecycleEvent(type: AppEventType) {
        let analyticsClient = pinpoint.analyticsClient
        let event = analyticsClient.createEvent(withEventType: type.rawValue)
        analyticsClient.record(event).continueOnSuccessWith { _ in
            print(">>> Events recorded...")
        }
    }

    // MARK: - Split View

    private func setupSplitView() {
        // Override point for customization after application launch.
        // swiftlint:disable:next force_cast
        let splitViewController = window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count - 1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        // swiftlint:disable:previous force_cast
        splitViewController.delegate = self
    }

    func splitViewController(_: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto _: UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse
            // by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }
}
