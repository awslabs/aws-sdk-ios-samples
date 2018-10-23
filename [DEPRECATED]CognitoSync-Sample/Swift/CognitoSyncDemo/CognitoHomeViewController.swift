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
import AWSCore

class CognitoHomeViewController: UIViewController {
    @IBOutlet weak var browseData: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var logoutWipe: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.disableUI()
        
        if AmazonClientManager.sharedInstance.isConfigured() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            AmazonClientManager.sharedInstance.resumeSession {
                (task) -> AnyObject! in
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshUI()
                }
                return nil
            }
        } else {
            let missingConfigAlert = UIAlertController(title: "Missing Configuration", message: "Please check Constants.swift and set appropriate values", preferredStyle: .Alert)
            missingConfigAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            self.presentViewController(missingConfigAlert, animated: true, completion: nil)
        }
    }
    

    @IBAction func loginClicked(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        self.disableUI()
        
        AmazonClientManager.sharedInstance.loginFromView(self) {
            (task: AWSTask!) -> AnyObject! in
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshUI()
                }
                return nil
        }
    }

    @IBAction func logoutClicked(sender: AnyObject) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.disableUI()
        
        AmazonClientManager.sharedInstance.logOut {
            (task) -> AnyObject! in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshUI()
            }
            return nil
        }
        
    }
    
    func disableUI() {
        self.browseData.enabled = false
        self.login.enabled = false
        self.logoutWipe.enabled = false
    }
    
    func refreshUI() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.browseData.enabled = true
        self.login.enabled = true
        let loggedIn = AmazonClientManager.sharedInstance.isLoggedIn()
        
        if loggedIn {
            self.login.setTitle("Link", forState: UIControlState.Normal)
        } else {
            self.login.setTitle("Login", forState: UIControlState.Normal)
        }
        self.logoutWipe.enabled = loggedIn
    }
}
