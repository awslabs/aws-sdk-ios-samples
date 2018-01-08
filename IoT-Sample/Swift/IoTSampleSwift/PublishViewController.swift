/*
* Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

class PublishViewController: UIViewController {

    @IBOutlet weak var publishSlider: UISlider!

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print("Publish slider value: " + "\(sender.value)")

        let iotDataManager = AWSIoTDataManager(forKey: ASWIoTDataManager)
        let tabBarViewController = tabBarController as! IoTSampleTabBarController

        iotDataManager.publishString("\(sender.value)", onTopic:tabBarViewController.topic, qoS:.messageDeliveryAttemptedAtMostOnce)
    }
}
