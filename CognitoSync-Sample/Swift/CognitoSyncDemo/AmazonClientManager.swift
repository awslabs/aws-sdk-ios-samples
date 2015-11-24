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
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import TwitterKit
import DigitsKit

class AmazonClientManager : NSObject, GPPSignInDelegate, AIAuthenticationDelegate {
    static let sharedInstance = AmazonClientManager()
    
    enum Provider: String {
        case FB,GOOGLE,AMAZON,TWITTER,DIGITS,BYOI
    }
    
    //KeyChain Constants
    let FB_PROVIDER = Provider.FB.rawValue
    let GOOGLE_PROVIDER = Provider.GOOGLE.rawValue
    let AMAZON_PROVIDER = Provider.AMAZON.rawValue
    let TWITTER_PROVIDER = Provider.TWITTER.rawValue
    let DIGITS_PROVIDER = Provider.DIGITS.rawValue
    let BYOI_PROVIDER = Provider.BYOI.rawValue
    
    
    //Properties
    var keyChain: UICKeyChainStore
    var completionHandler: AWSContinuationBlock?
    var fbLoginManager: FBSDKLoginManager?
    var gppSignIn: GPPSignIn?
    var googleAuth: GTMOAuth2Authentication?
    var credentialsProvider: AWSCognitoCredentialsProvider?
    var devAuthClient: DeveloperAuthenticationClient?
    var loginViewController: UIViewController?
    
    override init() {
        keyChain = UICKeyChainStore(service: NSBundle.mainBundle().bundleIdentifier!)
        devAuthClient = DeveloperAuthenticationClient(appname: Constants.DEVELOPER_AUTH_APP_NAME, endpoint: Constants.DEVELOPER_AUTH_ENDPOINT)
        
        super.init()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    // MARK: General Login
    
    func isConfigured() -> Bool {
        return !(Constants.COGNITO_IDENTITY_POOL_ID == "YourCognitoIdentityPoolId" || Constants.COGNITO_REGIONTYPE == AWSRegionType.Unknown)
    }
    
    func resumeSession(completionHandler: AWSContinuationBlock) {
        self.completionHandler = completionHandler
        
        if self.keyChain[BYOI_PROVIDER] != nil {
            self.reloadBYOISession()
        } else if self.keyChain[FB_PROVIDER] != nil {
            self.reloadFBSession()
        } else if self.keyChain[AMAZON_PROVIDER] != nil {
            self.amazonLogin()
        } else if self.keyChain[GOOGLE_PROVIDER] != nil {
            self.reloadGSession()
        } else if self.keyChain[TWITTER_PROVIDER] != nil {
            self.twitterLogin()
        } else if self.keyChain[DIGITS_PROVIDER] != nil {
            self.digitsLogin()
        }
        
        if self.credentialsProvider == nil {
            self.completeLogin(nil)
        }
    }
    
    //Sends the appropriate URL based on login provider
    func application(application: UIApplication,
        openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
            if GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
            
            if FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
                return true
            }
            
            if AIMobileLib.handleOpenURL(url, sourceApplication: sourceApplication) {
                return true
            }
            return false
    }
    
    func completeLogin(logins: [NSObject : AnyObject]?) {
        var task: AWSTask?
        
        if self.credentialsProvider == nil {
            task = self.initializeClients(logins)
        } else {
            var merge = [NSObject : AnyObject]()
            
            //Add existing logins
            if let previousLogins = self.credentialsProvider?.logins {
                merge = previousLogins
            }
            
            //Add new logins
            if let unwrappedLogins = logins {
                for (key, value) in unwrappedLogins {
                    merge[key] = value
                }
                self.credentialsProvider?.logins = merge
            }
            //Force a refresh of credentials to see if merge is necessary
            task = self.credentialsProvider?.refresh()
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
        }.continueWithBlock(self.completionHandler)
    }
    
    func initializeClients(logins: [NSObject : AnyObject]?) -> AWSTask? {
        print("Initializing Clients...")
        
        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose
        
        let identityProvider = DeveloperAuthenticatedIdentityProvider(
            regionType: Constants.COGNITO_REGIONTYPE,
            identityId: nil,
            identityPoolId: Constants.COGNITO_IDENTITY_POOL_ID,
            logins: logins,
            providerName: Constants.DEVELOPER_AUTH_PROVIDER_NAME,
            authClient: self.devAuthClient)
        self.credentialsProvider = AWSCognitoCredentialsProvider(regionType: Constants.COGNITO_REGIONTYPE, identityProvider: identityProvider, unauthRoleArn: nil, authRoleArn: nil)
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
        if self.isLoggedInWithFacebook() {
            self.fbLogout()
        } else if self.isLoggedInWithAmazon() {
            self.amazonLogout()
        } else if self.isLoggedInWithGoogle() {
            self.googleLogout()
        } else if self.isLoggedInWithTwitter() {
            self.twitterLogout()
        } else if self.isLoggedInWithDigits() {
            self.digitsLogout()
        }
        self.devAuthClient?.logout()
        
        // Wipe credentials
        self.credentialsProvider?.logins = nil
        AWSCognito.defaultCognito().wipe()
        self.credentialsProvider?.clearKeychain()
        
        AWSTask(result: nil).continueWithBlock(completionHandler)
    }
    
    func isLoggedIn() -> Bool {
        return isLoggedInWithFacebook() || isLoggedInWithGoogle() || isLoggedInWithTwitter() || isLoggedInWithDigits() || isLoggedInWithAmazon() || isLoggedInWithBYOI()
    }
    
    // MARK: Facebook Login
    
    func isLoggedInWithFacebook() -> Bool {
        let loggedIn = FBSDKAccessToken.currentAccessToken() != nil
        
        return self.keyChain[FB_PROVIDER] != nil && loggedIn
    }
    
    func reloadFBSession() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            print("Reloading Facebook Session")
            self.completeFBLogin()
        }
    }
    
    func fbLogin() {
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.completeFBLogin()
        } else {
            if self.fbLoginManager == nil {
                self.fbLoginManager = FBSDKLoginManager()
                self.fbLoginManager?.logInWithReadPermissions(nil) {
                    (result: FBSDKLoginManagerLoginResult!, error : NSError!) -> Void in
                    
                    if (error != nil) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.errorAlert("Error logging in with FB: " + error.localizedDescription)
                        }
                    } else if result.isCancelled {
                        //Do nothing
                    } else {
                        self.completeFBLogin()
                    }
                }
            }
        }
        
    }
    
    func fbLogout() {
        if self.fbLoginManager == nil {
            self.fbLoginManager = FBSDKLoginManager()
        }
        self.fbLoginManager?.logOut()
        self.keyChain[FB_PROVIDER] = nil
    }
    
    func completeFBLogin() {
        self.keyChain[FB_PROVIDER] = "YES"
        self.completeLogin(["graph.facebook.com" : FBSDKAccessToken.currentAccessToken().tokenString])
    }
    
    // MARK: Google Login
    
    func isLoggedInWithGoogle() -> Bool {
        let loggedIn = self.googleAuth != nil
        return self.keyChain[GOOGLE_PROVIDER] != nil && loggedIn
    }
    
    func reloadGSession() {
        print("Reloading Google session")
        self.gppSignIn?.trySilentAuthentication()
    }
    
    func googleLogin() {
        self.gppSignIn = GPPSignIn.sharedInstance()
        self.gppSignIn?.delegate = self
        self.gppSignIn?.clientID = Constants.GOOGLE_CLIENT_ID
        self.gppSignIn?.scopes = [Constants.GOOGLE_CLIENT_SCOPE, Constants.GOOGLE_OIDC_SCOPE]
        self.gppSignIn?.authenticate()
    }
    
    func googleLogout() {
        self.gppSignIn?.disconnect()
        self.googleAuth = nil
        self.keyChain[GOOGLE_PROVIDER] = nil
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        if self.googleAuth == nil {
            self.googleAuth = auth;
            
            if error != nil {
                self.errorAlert("Error logging in with Google: " + error.localizedDescription)
            } else {
                self.completeGoogleLogin()
            }
        }
    }
    
    func completeGoogleLogin() {
        self.keyChain[GOOGLE_PROVIDER] = "YES"
        if let idToken: AnyObject = self.googleAuth?.parameters.objectForKey("id_token") {
             self.completeLogin(["accounts.google.com": idToken])
        }
       
    }
    
    // MARK: Amazon Login
    
    func isLoggedInWithAmazon() -> Bool {
        return self.keyChain[AMAZON_PROVIDER] != nil
    }
    
    func amazonLogin() {
        print("Logging into Amazon")
        AIMobileLib.authorizeUserForScopes(["profile"], delegate: self)
    }
    
    func amazonLogout() {
        AIMobileLib.clearAuthorizationState(self)
        self.keyChain[AMAZON_PROVIDER] = nil
    }
    func requestDidSucceed(apiResult: APIResult!) {
        if apiResult.api == API.AuthorizeUser {
            AIMobileLib.getAccessTokenForScopes(["profile"], withOverrideParams: nil, delegate: self)
        } else if apiResult.api == API.GetAccessToken {
            self.keyChain[AMAZON_PROVIDER] = "YES"
            
            if let token: AnyObject = apiResult.result {
                self.completeLogin(["www.amazon.com" : token])
            }
        }
    }
    func requestDidFail(errorResponse: APIError!) {
        self.errorAlert("Error logging in with Amazon: " + errorResponse.description)
        
        AWSTask(result: nil).continueWithBlock(self.completionHandler)
    }
    
    // MARK: Twitter Login / Digits Login
    
    func isLoggedInWithTwitter() -> Bool {
        let loggedIn = Twitter.sharedInstance().session() != nil
        return self.keyChain[TWITTER_PROVIDER] != nil && loggedIn
    }
    
    func isLoggedInWithDigits() -> Bool {
        let loggedIn = Digits.sharedInstance().session() != nil
        return self.keyChain[DIGITS_PROVIDER] != nil && loggedIn
    }
    
    func twitterLogin() {
        print("Logging into Twitter")
        Twitter.sharedInstance().logInWithCompletion { (session, error) -> Void in
            if session != nil {
                self.completeTwitterLogin()
            } else if error != nil{
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert("Error logging in with Twitter: " + error!.localizedDescription)
                }
            } else {
                self.errorAlert("Unknown Error")
            }
        }
    }
    
    func twitterLogout() {
        Twitter.sharedInstance().logOut()
        self.keyChain[TWITTER_PROVIDER] = nil
    }
    
    func completeTwitterLogin() {
        self.keyChain[TWITTER_PROVIDER] = "YES"
        self.completeLogin(["api.twitter.com": self.loginForTwitterSession(Twitter.sharedInstance().session()!)])
    }
    
    func digitsLogin() {
        print("Logging into Digits")
        Digits.sharedInstance().authenticateWithCompletion { (session, error) -> Void in
            if (session != nil) {
                self.completeDigitsLogin()
            } else if error != nil{
                dispatch_async(dispatch_get_main_queue()) {
                    self.errorAlert("Error logging in with Digits: " + error.localizedDescription)
                }
            } else {
                self.errorAlert("Unknown Error")
            }
        }
    }
    
    func digitsLogout() {
        Digits.sharedInstance().logOut()
        self.keyChain[DIGITS_PROVIDER] = nil
    }
    
    func completeDigitsLogin() {
        self.keyChain[DIGITS_PROVIDER] = "YES"
        self.completeLogin(["www.digits.com": self.loginForTwitterSession(Digits.sharedInstance().session()!)])
    }
    
    func loginForTwitterSession(session: TWTRAuthSession) -> String {
        return session.authToken + ";" + session.authTokenSecret
    }
    
    // MARK: BYOI
    
    func isLoggedInWithBYOI() -> Bool {
        var loggedIn = false
        if let authClient = self.devAuthClient {
            loggedIn = authClient.isAuthenticated()
        }
        return (self.keyChain[BYOI_PROVIDER] != nil && loggedIn)
    }
    
    func reloadBYOISession() {
        print("Reloading Developer Authentication Session")
        self.completeLogin([Constants.DEVELOPER_AUTH_PROVIDER_NAME:self.keyChain[BYOI_PROVIDER]!])
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
                        self.errorAlert("Login failed. Check your username and password: " + task.error.localizedDescription)
                    }
                    AWSTask(error: task.error).continueWithBlock(self.completionHandler)
                } else {
                    self.keyChain[self.BYOI_PROVIDER] = username!
                    self.completeLogin([Constants.DEVELOPER_AUTH_PROVIDER_NAME: username!])
                }
                return nil
            })
        } else {
            AWSTask(result: nil).continueWithBlock(self.completionHandler)
        }
    }
    
    // MARK: UI Helpers
    
    func displayLoginSheet() {
        let loginProviders = UIAlertController(title: nil, message: "Login With:", preferredStyle: .ActionSheet)
        let fbLoginAction = UIAlertAction(title: "Facebook", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.fbLogin()
        }
        let googleLoginAction = UIAlertAction(title: "Google", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.googleLogin()
        }
        let amazonLoginAction = UIAlertAction(title: "Amazon", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.amazonLogin()
        }
        let twitterLoginAction = UIAlertAction(title: "Twitter", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.twitterLogin()
        }
        let digitsLoginAction = UIAlertAction(title: "Digits", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.digitsLogin()
        }
        let byoiLoginAction = UIAlertAction(title: "Developer Authenticated", style: .Default) {
            (alert: UIAlertAction) -> Void in
            self.BYOILogin()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (alert: UIAlertAction!) -> Void in
            AWSTask(result: nil).continueWithBlock(self.completionHandler)
        }
        
        loginProviders.addAction(fbLoginAction)
        loginProviders.addAction(googleLoginAction)
        loginProviders.addAction(amazonLoginAction)
        loginProviders.addAction(twitterLoginAction)
        loginProviders.addAction(digitsLoginAction)
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