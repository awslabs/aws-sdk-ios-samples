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

extension ConnectionViewController {
    
    func mqttEventCallbackWebsocket(_ status: AWSIoTMQTTStatus) {
        guard case .connected = status else {
            mqttEventCallback(status)
            return
        }

        DispatchQueue.main.async {
            let tabBarViewController = self.tabBarController as! IoTSampleTabBarController
            tabBarViewController.mqttStatus = "Connected"
            self.activityIndicatorView.stopAnimating()
            self.connected = true
            self.connectIoTDataWebSocket.setTitle("Disconnect \(self.IOT_WEBSOCKET)", for:UIControl.State())
            self.logTextView.text = "Connected via websocket"
            self.connectIoTDataWebSocket.isEnabled = true
            tabBarViewController.viewControllers = [ self, self.publishViewController, self.subscribeViewController ]
        }
    }
    
    @objc func didTapConnectIoTDataWebSocket(_ sender: UIButton) {
        sender.isEnabled = false
        if (connected == false) {
            handleConnectViaWebsocket()
        } else {
            handleDisconnect()
            DispatchQueue.main.async {
                sender.setTitle("Connect \(self.IOT_WEBSOCKET)", for:UIControl.State())
                sender.isEnabled = true
            }
        }
    }
    
    func handleConnectViaWebsocket() {
        self.connectButton.isHidden = true
        activityIndicatorView.startAnimating()
        DispatchQueue.main.async {
            self.logTextView.text = "Connecting (data plane)..."
        }
        let uuid = UUID().uuidString
        // Connect to the AWS IoT data plane service over websocket
        iotDataManager.connectUsingWebSocket(withClientId: uuid, cleanSession: true, statusCallback: mqttEventCallbackWebsocket(_:))
    }
}
