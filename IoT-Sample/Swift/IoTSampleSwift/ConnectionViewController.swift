/*
* Copyright 2010-2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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
import AWSMobileClient

class ConnectionViewController: UIViewController, UITextViewDelegate {

    let IOT_CERT = "IoT Cert"
    let IOT_WEBSOCKET = "IoT Websocket"

    var connectIoTDataWebSocket: UIButton!
    var activityIndicatorView: UIActivityIndicatorView!
    var logTextView: UITextView!
    var connectButton: UIButton!
    
    @objc var connected = false
    @objc var publishViewController : UIViewController!
    @objc var subscribeViewController : UIViewController!
    @objc var configurationViewController : UIViewController!

    @objc var iotDataManager: AWSIoTDataManager!
    @objc var iotManager: AWSIoTManager!
    @objc var iot: AWSIoT!

    func mqttEventCallback( _ status: AWSIoTMQTTStatus ) {
        DispatchQueue.main.async {
            let tabBarViewController = self.tabBarController as! IoTSampleTabBarController
            print("connection status = \(status.rawValue)")

            switch status {
            case .connecting:
                tabBarViewController.mqttStatus = "Connecting..."
                print( tabBarViewController.mqttStatus )
                self.logTextView.text = tabBarViewController.mqttStatus
                
            case .connected:
                tabBarViewController.mqttStatus = "Connected"
                print( tabBarViewController.mqttStatus )
                self.connectButton.setTitle( "Disconnect \(self.IOT_CERT)", for:UIControl.State())
                self.activityIndicatorView.stopAnimating()
                self.connected = true
                self.connectButton.isEnabled = true
                let uuid = UUID().uuidString;
                let defaults = UserDefaults.standard
                let certificateId = defaults.string( forKey: "certificateId")
                
                self.logTextView.text = "Using certificate:\n\(certificateId!)\n\n\nClient ID:\n\(uuid)"
                
                tabBarViewController.viewControllers = [ self, self.publishViewController, self.subscribeViewController ]
                
            case .disconnected:
                tabBarViewController.mqttStatus = "Disconnected"
                print( tabBarViewController.mqttStatus )
                self.activityIndicatorView.stopAnimating()
                self.logTextView.text = nil
                
            case .connectionRefused:
                tabBarViewController.mqttStatus = "Connection Refused"
                print( tabBarViewController.mqttStatus )
                self.activityIndicatorView.stopAnimating()
                self.logTextView.text = tabBarViewController.mqttStatus
                
            case .connectionError:
                tabBarViewController.mqttStatus = "Connection Error"
                print( tabBarViewController.mqttStatus )
                self.activityIndicatorView.stopAnimating()
                self.logTextView.text = tabBarViewController.mqttStatus
                
            case .protocolError:
                tabBarViewController.mqttStatus = "Protocol Error"
                print( tabBarViewController.mqttStatus )
                self.activityIndicatorView.stopAnimating()
                self.logTextView.text = tabBarViewController.mqttStatus
                
            default:
                tabBarViewController.mqttStatus = "Unknown State"
                print("unknown state: \(status.rawValue)")
                self.activityIndicatorView.stopAnimating()
                self.logTextView.text = tabBarViewController.mqttStatus
            }
            
            NotificationCenter.default.post( name: Notification.Name(rawValue: "connectionStatusChanged"), object: self )
        }
    }
    
    @objc func connectButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        if (connected == false) {
            handleConnectViaCert()
        } else {
            handleDisconnect()
            DispatchQueue.main.async {
                sender.setTitle("Connect \(self.IOT_CERT)", for:UIControl.State())
                sender.isEnabled = true
            }
        }
    }

    func handleConnectViaCert() {
        self.connectIoTDataWebSocket.isHidden = true
        activityIndicatorView.startAnimating()
        
        let defaults = UserDefaults.standard
        let certificateId = defaults.string( forKey: "certificateId")
        if (certificateId == nil) {
            DispatchQueue.main.async {
                self.logTextView.text = "No identity available, searching bundle..."
            }
            let certificateIdInBundle = searchForExistingCertificateIdInBundle()
            
            if (certificateIdInBundle == nil) {
                DispatchQueue.main.async {
                    self.logTextView.text = "No identity found in bundle, creating one..."
                }
                createCertificateIdAndStoreinNSUserDefaults(onSuccess: {generatedCertificateId in
                    let uuid = UUID().uuidString
                    self.logTextView.text = "Using certificate: \(generatedCertificateId)"
                    self.iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:generatedCertificateId, statusCallback: self.mqttEventCallback)
                }, onFailure: {error in
                    print("Received error: \(error)")
                })
            }
        } else {
            let uuid = UUID().uuidString;
            // Connect to the AWS IoT data plane service w/ certificate
            iotDataManager.connect( withClientId: uuid, cleanSession:true, certificateId:certificateId!, statusCallback: self.mqttEventCallback)
        }
    }

    func searchForExistingCertificateIdInBundle() -> String? {
        let defaults = UserDefaults.standard
        // No certificate ID has been stored in the user defaults; check to see if any .p12 files
        // exist in the bundle.
        let myBundle = Bundle.main
        let myImages = myBundle.paths(forResourcesOfType: "p12" as String, inDirectory:nil)
        let uuid = UUID().uuidString

        guard let certId = myImages.first else {
            let certificateId = defaults.string(forKey: "certificateId")
            return certificateId
        }
        
        // A PKCS12 file may exist in the bundle.  Attempt to load the first one
        // into the keychain (the others are ignored), and set the certificate ID in the
        // user defaults as the filename.  If the PKCS12 file requires a passphrase,
        // you'll need to provide that here; this code is written to expect that the
        // PKCS12 file will not have a passphrase.
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: certId)) else {
            print("[ERROR] Found PKCS12 File in bundle, but unable to use it")
            let certificateId = defaults.string( forKey: "certificateId")
            return certificateId
        }
        
        DispatchQueue.main.async {
            self.logTextView.text = "found identity \(certId), importing..."
        }
        if AWSIoTManager.importIdentity( fromPKCS12Data: data, passPhrase:"", certificateId:certId) {
            // Set the certificate ID and ARN values to indicate that we have imported
            // our identity from the PKCS12 file in the bundle.
            defaults.set(certId, forKey:"certificateId")
            defaults.set("from-bundle", forKey:"certificateArn")
            DispatchQueue.main.async {
                self.logTextView.text = "Using certificate: \(certId))"
                self.iotDataManager.connect( withClientId: uuid,
                                             cleanSession:true,
                                             certificateId:certId,
                                             statusCallback: self.mqttEventCallback)
            }
        }
        
        let certificateId = defaults.string( forKey: "certificateId")
        return certificateId
    }

    func createCertificateIdAndStoreinNSUserDefaults(onSuccess:  @escaping (String)->Void,
                                                     onFailure: @escaping (Error) -> Void) {
        let defaults = UserDefaults.standard
        // Now create and store the certificate ID in NSUserDefaults
        let csrDictionary = [ "commonName": CertificateSigningRequestCommonName,
                              "countryName": CertificateSigningRequestCountryName,
                              "organizationName": CertificateSigningRequestOrganizationName,
                              "organizationalUnitName": CertificateSigningRequestOrganizationalUnitName]
        
        self.iotManager.createKeysAndCertificate(fromCsr: csrDictionary) { (response) -> Void in
            guard let response = response else {
                DispatchQueue.main.async {
                    self.connectButton.isEnabled = true
                    self.activityIndicatorView.stopAnimating()
                    self.logTextView.text = "Unable to create keys and/or certificate, check values in Constants.swift"
                }
                onFailure(NSError(domain: "No response on iotManager.createKeysAndCertificate", code: -2, userInfo: nil))
                return
            }
            defaults.set(response.certificateId, forKey:"certificateId")
            defaults.set(response.certificateArn, forKey:"certificateArn")
            let certificateId = response.certificateId
            print("response: [\(String(describing: response))]")
            
            let attachPrincipalPolicyRequest = AWSIoTAttachPrincipalPolicyRequest()
            attachPrincipalPolicyRequest?.policyName = POLICY_NAME
            attachPrincipalPolicyRequest?.principal = response.certificateArn
            
            // Attach the policy to the certificate
            self.iot.attachPrincipalPolicy(attachPrincipalPolicyRequest!).continueWith (block: { (task) -> AnyObject? in
                if let error = task.error {
                    print("Failed: [\(error)]")
                    onFailure(error)
                } else  {
                    print("result: [\(String(describing: task.result))]")
                    DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                        if let certificateId = certificateId {
                            onSuccess(certificateId)
                        } else {
                            onFailure(NSError(domain: "Unable to generate certificate id", code: -1, userInfo: nil))
                        }
                    })
                }
                return nil
            })
        }
    }

    func handleDisconnect() {
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        self.connectButton.isHidden = false
        self.connectIoTDataWebSocket.isHidden = false
        activityIndicatorView.startAnimating()
        logTextView.text = "Disconnecting..."
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.iotDataManager.disconnect();
            DispatchQueue.main.async {
                self.connected = false
                tabBarViewController.viewControllers = [ self, self.configurationViewController ]
            }
        }
    }

    /*
    *  This function sets two methods for to connecting to IoT
    *  1.  Which uses a websocket to connect to an account specific endpoint you can get from the IoT Core Console
    *  2.  Which requests for a cert to the IoT control-plane and then uses that cert to connect to the data plane
    *  We would expect most users of the AWS IoT SDK for iOS to use one or the other, but not both.  Nonetheless, we have
    *  both of these examples in the same view controller.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewComponents()
       
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        publishViewController = tabBarViewController.viewControllers![1]
        subscribeViewController = tabBarViewController.viewControllers![2]
        configurationViewController = tabBarViewController.viewControllers![3]

        tabBarViewController.viewControllers = [ self, configurationViewController ]
        logTextView.resignFirstResponder()

        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:AWS_REGION,
                                                                identityPoolId:IDENTITY_POOL_ID)
        initializeControlPlane(credentialsProvider: credentialsProvider)
        initializeDataPlane(credentialsProvider: credentialsProvider)
    }

    func initializeControlPlane(credentialsProvider: AWSCredentialsProvider) {
        //Initialize control plane
        // Initialize the Amazon Cognito credentials provider
        let controlPlaneServiceConfiguration = AWSServiceConfiguration(region:AWS_REGION, credentialsProvider:credentialsProvider)
        
        //IoT control plane seem to operate on iot.<region>.amazonaws.com
        //Set the defaultServiceConfiguration so that when we call AWSIoTManager.default(), it will get picked up
        AWSServiceManager.default().defaultServiceConfiguration = controlPlaneServiceConfiguration
        iotManager = AWSIoTManager.default()
        iot = AWSIoT.default()
    }
    
    func initializeDataPlane(credentialsProvider: AWSCredentialsProvider) {
        //Initialize Dataplane:
        // IoT Dataplane must use your account specific IoT endpoint
        let iotEndPoint = AWSEndpoint(urlString: IOT_ENDPOINT)
        
        // Configuration for AWSIoT data plane APIs
        let iotDataConfiguration = AWSServiceConfiguration(region: AWS_REGION,
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentialsProvider)
        //IoTData manager operates on xxxxxxx-iot.<region>.amazonaws.com
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: AWS_IOT_DATA_MANAGER_KEY)
        iotDataManager = AWSIoTDataManager(forKey: AWS_IOT_DATA_MANAGER_KEY)
    }

    func setupViewComponents() {
        let labelHeight = 44 * 4
        
        let buttonWidth = 300
        let buttonHeight = 44
        let spacer = 10
        let x = 44
        var y = 100
        
        connectIoTDataWebSocket = UIButton(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight))
        connectIoTDataWebSocket.setTitle("Connect \(self.IOT_WEBSOCKET)", for: .normal)
        connectIoTDataWebSocket.tintColor = .black
        connectIoTDataWebSocket.backgroundColor = .lightGray

        y += spacer + buttonHeight
        
        connectButton = UIButton(frame: CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight))
        connectButton.setTitle("Connect \(self.IOT_CERT)", for: .normal)
        connectButton.tintColor = .black
        connectButton.backgroundColor = .lightGray

        y += spacer + buttonHeight
        logTextView = UITextView(frame: CGRect(x: 5, y: y, width: 300, height: labelHeight))
        y += spacer + labelHeight
        activityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: x, y: y, width: 44, height: 44))
        
        connectIoTDataWebSocket.addTarget(self, action: #selector(didTapConnectIoTDataWebSocket(_:)), for: .touchUpInside)
        connectButton.addTarget(self, action: #selector(connectButtonPressed(_:)), for: .touchUpInside)
        
        self.view.addSubview(connectIoTDataWebSocket)
        self.view.addSubview(connectButton)

        self.view.addSubview(logTextView)
        self.view.addSubview(activityIndicatorView)
    }
}

