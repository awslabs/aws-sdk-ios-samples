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

class ConfigurationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var deleteCertificateButton: UIButton!
    @IBOutlet weak var topicTextField: UITextField!

    @IBAction func deleteCertificateButtonPressed(sender: AnyObject) {
        let actionController: UIAlertController = UIAlertController( title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction: UIAlertAction = UIAlertAction( title: "Cancel", style: .Cancel) { action -> Void in
        }
        actionController.addAction( cancelAction )

        let okAction: UIAlertAction = UIAlertAction( title: "Delete", style: .Default) { action -> Void in
            print( "deleting certificate...")

            //
            // To delete the certificate:
            //
            //  1) Set the certificate's status to 'inactive'
            //  2) Detach the policy from the certificate
            //  3) Delete the certificate
            //  4) Remove the keys and certificate from the keychain
            //  5) Delete user defaults
            //
            let defaults = NSUserDefaults.standardUserDefaults()
            let certificateId = defaults.stringForKey( "certificateId")

            if (certificateId != nil)
            {
                let iot = AWSIoT.defaultIoT()

                let updateCertificateRequest = AWSIoTUpdateCertificateRequest()
                updateCertificateRequest.certificateId = certificateId
                updateCertificateRequest.latestStatus = .Inactive

                iot.updateCertificate( updateCertificateRequest ).continueWithBlock { (task) -> AnyObject? in

                    if let error = task.error {
                        print("failed: [\(error)]")
                    }
                    if let exception = task.exception {
                        print("failed: [\(exception)]")
                    }
                    print("result: [\(task.result)]")
                    if (task.exception == nil && task.error == nil)
                    {
                        //
                        // The certificate is now inactive; detach the policy from the
                        // certificate.
                        //
                        let certificateArn = defaults.stringForKey( "certificateArn")
                        let detachPolicyRequest = AWSIoTDetachPrincipalPolicyRequest()
                        detachPolicyRequest.principal = certificateArn
                        detachPolicyRequest.policyName = PolicyName

                        iot.detachPrincipalPolicy(detachPolicyRequest).continueWithBlock { (task) -> AnyObject? in
                            if let error = task.error {
                                print("failed: [\(error)]")
                            }
                            if let exception = task.exception {
                                print("failed: [\(exception)]")
                            }
                            print("result: [\(task.result)]")
                            if (task.exception == nil && task.error == nil)
                            {
                                //
                                // The policy is now detached; delete the certificate
                                //
                                let deleteCertificateRequest = AWSIoTDeleteCertificateRequest()
                                deleteCertificateRequest.certificateId = certificateId

                                iot.deleteCertificate(deleteCertificateRequest).continueWithBlock { (task) -> AnyObject? in

                                    if let error = task.error {
                                        print("failed: [\(error)]")
                                    }
                                    if let exception = task.exception {
                                        print("failed: [\(exception)]")
                                    }
                                    print("result: [\(task.result)]")
                                    if (task.exception == nil && task.error == nil)
                                    {
                                        //
                                        // The certificate has been deleted; now delete the keys
                                        // and certificate from the keychain.
                                        //
                                        if (AWSIoTManager.deleteCertificate() != true)
                                        {
                                            print("error deleting certificate")
                                        }
                                        else
                                        {
                                            defaults.removeObjectForKey("certificateId")
                                            defaults.removeObjectForKey("certificateArn")
                                            dispatch_async( dispatch_get_main_queue() ) {
                                                self.tabBarController?.selectedIndex = 0
                                            }
                                        }
                                    }
                                    return nil
                                }
                            }
                            return nil
                        }
                    }
                    return nil
                }

            }
            else
            {
                print("certificate id == nil!")   // shouldn't be possible
            }

        }
        actionController.addAction( okAction )
        self.presentViewController( actionController, animated: true, completion: nil )
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        topicTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        topicTextField.text = textField.text
        let defaults = NSUserDefaults.standardUserDefaults()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        tabBarViewController.topic=textField.text!
        defaults.setObject(textField.text, forKey:"sliderTopic")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topicTextField.delegate = self
        let defaults = NSUserDefaults.standardUserDefaults()
        let certificateId = defaults.stringForKey( "certificateId")
        let sliderTopic = defaults.stringForKey( "sliderTopic" )
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        if (certificateId == nil)
        {
            deleteCertificateButton.hidden=true
        }
        if (sliderTopic != nil)
        {
            tabBarViewController.topic=sliderTopic!
        }
        topicTextField.text = tabBarViewController.topic
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        let certificateId = defaults.stringForKey( "certificateId")

        if (certificateId == nil)
        {
            deleteCertificateButton.hidden=true
        }
        else
        {
            deleteCertificateButton.hidden=false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}