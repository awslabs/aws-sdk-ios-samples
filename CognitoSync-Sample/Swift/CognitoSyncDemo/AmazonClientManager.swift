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
import UICKeyChainStore
import AWSCore
import AWSCognito

class AmazonClientManager : NSObject {
    static let sharedInstance = AmazonClientManager()

    //Properties
    var keyChain: UICKeyChainStore
    var completionHandler: AWSContinuationBlock?
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var devAuthClient: DeveloperAuthenticationClient?
    var loginViewController: UIViewController?

    override init() {
        keyChain = UICKeyChainStore(service: "\(NSBundle.mainBundle().bundleIdentifier!).\(AmazonClientManager.self)")
        print("UICKeyChainStore: \(NSBundle.mainBundle().bundleIdentifier!).\(AmazonClientManager.self)")
        devAuthClient = DeveloperAuthenticationClient(appname: Constants.DEVELOPER_AUTH_APP_NAME, endpoint: Constants.DEVELOPER_AUTH_ENDPOINT)

        super.init()
    }

    // MARK: General Login

    func isConfigured() -> Bool {
        return !(Constants.COGNITO_IDENTITY_POOL_ID == "YourCognitoIdentityPoolId" || Constants.COGNITO_REGIONTYPE == AWSRegionType.Unknown)
    }

    func resumeSession(completionHandler: AWSContinuationBlock) {
        self.completionHandler = completionHandler

        if self.keyChain[Constants.BYOI_PROVIDER] != nil {
            self.reloadBYOISession()
        }

        if self.credentialsProvider == nil {
            self.completeLogin(nil)
        }
    }

    func completeLogin(logins: [NSObject : AnyObject]?) {
        var task: AWSTask?

        if self.credentialsProvider == nil {
            task = self.initializeClients(logins)
        } else {
            credentialsProvider?.invalidateCachedTemporaryCredentials()
            task = credentialsProvider?.getIdentityId()
        }
        task?.continueWithBlock {
            (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                let currentDeviceToken: NSData? = userDefaults.objectForKey(Constants.DEVICE_TOKEN_KEY) as? NSData
                var currentDeviceTokenString : String

                if currentDeviceToken != nil {
                    currentDeviceTokenString = currentDeviceToken!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                } else {
                    currentDeviceTokenString = ""
                }

                if currentDeviceToken != nil && currentDeviceTokenString != userDefaults.stringForKey(Constants.COGNITO_DEVICE_TOKEN_KEY) {

                    AWSCognito.defaultCognito().registerDevice(currentDeviceToken).continueWithBlock { (task: AWSTask!) -> AnyObject! in
                        if (task.error == nil) {
                            userDefaults.setObject(currentDeviceTokenString, forKey: Constants.COGNITO_DEVICE_TOKEN_KEY)
                            userDefaults.synchronize()
                        }
                        return nil
                    }
                }
            }
            return task
            }.continueWithBlock(self.completionHandler!)
    }

    func initializeClients(logins: [NSObject : AnyObject]?) -> AWSTask? {
        print("Initializing Clients...")

        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose

        let identityProvider = DeveloperAuthenticatedIdentityProvider(
            regionType: Constants.COGNITO_REGIONTYPE,
            identityPoolId: Constants.COGNITO_IDENTITY_POOL_ID,
            providerName: Constants.DEVELOPER_AUTH_PROVIDER_NAME,
            authClient: self.devAuthClient,
            identityProviderManager: nil)

        self.credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: Constants.COGNITO_REGIONTYPE,
            unauthRoleArn: nil,
            authRoleArn: nil,
            identityProvider: identityProvider)
        let configuration = AWSServiceConfiguration(region: Constants.COGNITO_REGIONTYPE, credentialsProvider: self.credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

        return self.credentialsProvider?.getIdentityId()
    }

    func loginFromView(theViewController: UIViewController, withCompletionHandler completionHandler: AWSContinuationBlock) {
        self.completionHandler = completionHandler
        self.loginViewController = theViewController
        self.displayLoginSheet()
    }

    func logOut(completionHandler: AWSContinuationBlock) {
        self.devAuthClient?.logout()

        AWSCognito.defaultCognito().wipe()
        self.credentialsProvider?.clearKeychain()

        AWSTask(result: nil).continueWithBlock(completionHandler)
    }

    func isLoggedIn() -> Bool {
        return isLoggedInWithBYOI()
    }


    // MARK: BYOI

    func isLoggedInWithBYOI() -> Bool {
        var loggedIn = false
        if let authClient = self.devAuthClient {
            loggedIn = authClient.isAuthenticated()
        }
        return (self.keyChain[Constants.BYOI_PROVIDER] != nil && loggedIn)
    }

    func reloadBYOISession() {
        print("Reloading Developer Authentication Session")
        self.completeLogin([Constants.DEVELOPER_AUTH_PROVIDER_NAME:self.keyChain[Constants.BYOI_PROVIDER]!])
    }

    func BYOILogin() {
        var username: UITextField!
        var password: UITextField!
        let BYOILoginAlert = UIAlertController(title: "Login", message: "Enter Developer Authenticated Account Credentials", preferredStyle: UIAlertControllerStyle.Alert)

        BYOILoginAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Username"
            username = textField
        }
        BYOILoginAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
            password = textField
        }

        let loginAction = UIAlertAction(title: "Login", style: .Default) { (action) -> Void in
            self.completeBYOILogin(username.text, password: password.text)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        BYOILoginAlert.addAction(loginAction)
        BYOILoginAlert.addAction(cancelAction)

        self.loginViewController?.presentViewController(BYOILoginAlert, animated: true, completion: nil)
    }

    func completeBYOILogin( username: String?, password: String?) {
        if username != nil && password != nil {
            self.devAuthClient?.login(username, password: password).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task) -> AnyObject! in

                if task.cancelled {
                    self.errorAlert("Login Canceled")
                } else if task.error != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.errorAlert("Login failed. Check your username and password: " + task.error!.localizedDescription)
                    }
                    AWSTask(error: task.error!).continueWithBlock(self.completionHandler!)
                } else {
                    self.keyChain[Constants.BYOI_PROVIDER] = username!
                    self.completeLogin([Constants.DEVELOPER_AUTH_PROVIDER_NAME: username!])
                }
                return nil
            })
        } else {
            AWSTask(result: nil).continueWithBlock(self.completionHandler!)
        }
    }

    // MARK: UI Helpers

    func displayLoginSheet() {
        let loginProviders = UIAlertController(title: nil, message: "Login With:", preferredStyle: .ActionSheet)

        let byoiLoginAction = UIAlertAction(title: "Developer Authenticated", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.BYOILogin()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (alert: UIAlertAction!) -> Void in
            AWSTask(result: nil).continueWithBlock(self.completionHandler!)
        }

        loginProviders.addAction(byoiLoginAction)
        loginProviders.addAction(cancelAction)

        self.loginViewController?.presentViewController(loginProviders, animated: true, completion: nil)
    }

    func errorAlert(message: String) {
        let errorAlert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Ok", style: .Default) { (alert: UIAlertAction) -> Void in }

        errorAlert.addAction(okAction)

        self.loginViewController?.presentViewController(errorAlert, animated: true, completion: nil)
    }
}