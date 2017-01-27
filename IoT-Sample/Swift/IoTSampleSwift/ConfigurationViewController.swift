/*
* Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
import AWSIoT

class ConfigurationViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var deleteCertificateButton: UIButton!
    @IBOutlet weak var topicTextField: UITextField!

    @IBAction func deleteCertificateButtonPressed(_ sender: AnyObject) {
        let actionController: UIAlertController = UIAlertController( title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction( title: "Cancel", style: .cancel) { action -> Void in
        }
        actionController.addAction( cancelAction )

        let okAction: UIAlertAction = UIAlertAction( title: "Delete", style: .default) { action -> Void in
            print( "deleting identity...")

            //
            // To delete an identity created via the API:
            //
            //  1) Set the certificate's status to 'inactive'
            //  2) Detach the policy from the certificate
            //  3) Delete the certificate
            //  4) Remove the keys and certificate from the keychain
            //  5) Delete user defaults
            //
            // To delete an identity created via a PKCS12 file in the bundle:
            //
            //  1) Remove the keys and certificate from the keychain
            //  2) Delete user defaults
            //
            let defaults = UserDefaults.standard
            let certificateId = defaults.string( forKey: "certificateId")
            let certificateArn = defaults.string( forKey: "certificateArn")
            
            if certificateArn != "from-bundle" && certificateId != nil
            {
                let iot = AWSIoT.default()

                let updateCertificateRequest = AWSIoTUpdateCertificateRequest()
                updateCertificateRequest?.certificateId = certificateId
                updateCertificateRequest?.latestStatus = .inactive

                iot.updateCertificate( updateCertificateRequest! ).continueWith(block:{ (task) -> AnyObject? in

                    if let error = task.error {
                        print("failed: [\(error)]")
                    }
                    print("result: [\(task.result)]")
                    if (task.error == nil)
                    {
                        //
                        // The certificate is now inactive; detach the policy from the
                        // certificate.
                        //
                        let certificateArn = defaults.string( forKey: "certificateArn")
                        let detachPolicyRequest = AWSIoTDetachPrincipalPolicyRequest()
                        detachPolicyRequest?.principal = certificateArn
                        detachPolicyRequest?.policyName = PolicyName

                        iot.detachPrincipalPolicy(detachPolicyRequest!).continueWith(block: { (task) -> AnyObject? in
                            if let error = task.error {
                                print("failed: [\(error)]")
                            }
                            print("result: [\(task.result)]")
                            if (task.error == nil)
                            {
                                //
                                // The policy is now detached; delete the certificate
                                //
                                let deleteCertificateRequest = AWSIoTDeleteCertificateRequest()
                                deleteCertificateRequest?.certificateId = certificateId

                                iot.deleteCertificate(deleteCertificateRequest!).continueWith(block: { (task) -> AnyObject? in

                                    if let error = task.error {
                                        print("failed: [\(error)]")
                                    }
                                    print("result: [\(task.result)]")
                                    if (task.error == nil)
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
                                            defaults.removeObject(forKey: "certificateId")
                                            defaults.removeObject(forKey: "certificateArn")
                                            DispatchQueue.main.async {
                                                self.tabBarController?.selectedIndex = 0
                                            }
                                        }
                                    }
                                    return nil
                                })
                            }
                            return nil
                        })
                    }
                    return nil
                })

            }
            else if certificateArn == "from-bundle"
            {
                //
                // Delete the keys and certificate from the keychain.
                //
                if (AWSIoTManager.deleteCertificate() != true)
                {
                    print("error deleting certificate")
                }
                else
                {
                    defaults.removeObject(forKey: "certificateId")
                    defaults.removeObject(forKey: "certificateArn")
                    DispatchQueue.main.async {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
            else
            {
                print("certificate id == nil!")   // shouldn't be possible
            }

        }
        actionController.addAction( okAction )
        self.present( actionController, animated: true, completion: nil )
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topicTextField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        topicTextField.text = textField.text
        let defaults = UserDefaults.standard
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        tabBarViewController.topic=textField.text!
        defaults.set(textField.text, forKey:"sliderTopic")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        topicTextField.delegate = self
        let defaults = UserDefaults.standard
        let certificateId = defaults.string( forKey: "certificateId")
        let sliderTopic = defaults.string( forKey: "sliderTopic" )
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        if (certificateId == nil)
        {
            deleteCertificateButton.isHidden=true
        }
        if (sliderTopic != nil)
        {
            tabBarViewController.topic=sliderTopic!
        }
        topicTextField.text = tabBarViewController.topic
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let certificateId = defaults.string( forKey: "certificateId")

        if (certificateId == nil)
        {
            deleteCertificateButton.isHidden=true
        }
        else
        {
            deleteCertificateButton.isHidden=false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
