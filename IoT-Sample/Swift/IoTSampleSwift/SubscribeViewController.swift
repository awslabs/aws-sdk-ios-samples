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

class SubscribeViewController: UIViewController {

    @IBOutlet weak var subscribeSlider: UISlider!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        subscribeSlider.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        iotDataManager.subscribe(toTopic: tabBarViewController.topic, qoS: .messageDeliveryAttemptedAtMostOnce, messageCallback: {
            (payload) ->Void in
            let stringValue = NSString(data: payload, encoding: String.Encoding.utf8.rawValue)!

            print("received: \(stringValue)")
            DispatchQueue.main.async {
                self.subscribeSlider.value = stringValue.floatValue
            }
        } )
    }

    override func viewWillDisappear(_ animated: Bool) {
        let iotDataManager = AWSIoTDataManager.default()
        let tabBarViewController = tabBarController as! IoTSampleTabBarController
        iotDataManager.unsubscribeTopic(tabBarViewController.topic)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

