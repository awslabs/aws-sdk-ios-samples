/*
* Copyright 2010-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

class MainViewController: UIViewController {
    @IBOutlet weak var deviceToken: UILabel?
    @IBOutlet weak var endpointArn: UILabel?
    @IBOutlet weak var userAction: UILabel?

    func displayDeviceInfo() {
        deviceToken?.text = NSUserDefaults.standardUserDefaults().stringForKey("deviceToken") ?? "N/A"
        endpointArn?.text = NSUserDefaults.standardUserDefaults().stringForKey("endpointArn") ?? "N/A"
    }

    func displayUserAction(action: NSString?) {
        if action == nil {
            userAction?.text = "---"
        } else {
            userAction?.text = "The user selected [" + action! + "]"
        }
    }
}
