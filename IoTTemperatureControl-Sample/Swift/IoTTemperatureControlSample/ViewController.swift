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
import AWSCore
import AWSIoT
import SwiftyJSON

//
// These values must match the values from the temperature-control example
// in the aws-iot-device-sdk.js package (https://github.com/aws/aws-iot-device-sdk-js)
//
let statusThingName="TemperatureStatus"
let controlThingName="TemperatureControl"

class ViewController: UIViewController {
    @IBOutlet weak var setpointLabel: UILabel!
    @IBOutlet weak var interiorLabel: UILabel!
    @IBOutlet weak var exteriorLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var setpointStepper: UIStepper!

    var interiorTemperature: Int = 70;
    var exteriorTemperature: Int = 45;
    var currentRunningState: String="stopped";
    var currentlyEnabled: Bool = true;
    var currentSetpoint: Int = 68;
    weak var pollingTimer: NSTimer?;
    
    func updateThingShadow( thingName: String, jsonData: JSON )
    {
        let updateThingShadowRequest = AWSIoTDataUpdateThingShadowRequest()
        updateThingShadowRequest.thingName = thingName
        do {
            let tmpVal = try jsonData.rawData()

            let IoTData = AWSIoTData.defaultIoTData()
            
            updateThingShadowRequest.payload = tmpVal
            IoTData.updateThingShadow(updateThingShadowRequest).continueWithBlock { (task) -> AnyObject? in
                if let error = task.error {
                    print("failed: [\(error)]")
                }
                if let exception = task.exception {
                    print("failed: [\(exception)]")
                }
                if (task.error == nil && task.exception == nil) {
                    // let result = task.result!
                    // let json = JSON(data: result.payload as NSData!)
                    //
                    // The latest state of the device shadow is in 'json'
                    //
                }
                //
                // Re-enable polling
                //
                dispatch_async( dispatch_get_main_queue()) {
                    if (self.pollingTimer == nil) {
                        self.pollingTimer = NSTimer.scheduledTimerWithTimeInterval( 0.5, target: self, selector: "getThingStates", userInfo: nil, repeats: true )
                    }
                }
                return nil
            }
        }
        catch {
            print("couldn't convert to raw")
        }
    }

    @IBAction func statusSwitchChanged(sender: UISwitch) {
        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [ "setPoint": currentSetpoint, "enabled": sender.on]]])
        //
        // Disable polling while waiting on a response from updating the thing shadow
        //
        if (self.pollingTimer != nil) {
            self.pollingTimer?.invalidate();
        }
        updateThingShadow( controlThingName, jsonData: controlJson )
    }
    
    @IBAction func setpointStepperTapped(sender: UIStepper) {
        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [ "setPoint": Int(sender.value), "enabled": currentlyEnabled]]])
        //
        // Disable polling while waiting on a response from updating the thing shadow
        //
        if (self.pollingTimer != nil) {
            self.pollingTimer?.invalidate();
        }
        currentSetpoint = Int(setpointStepper.value)
        setpointLabel.text = String(currentSetpoint)
        updateThingShadow( controlThingName, jsonData: controlJson )
    }
    
    func getThingState( thingName: String, completion: (String, JSON) -> Void )
    {
        let IoTData = AWSIoTData.defaultIoTData()

        let getThingShadowRequest = AWSIoTDataGetThingShadowRequest()
        getThingShadowRequest.thingName = thingName
        IoTData.getThingShadow(getThingShadowRequest).continueWithBlock { (task) -> AnyObject? in
            if let error = task.error {
                print("failed: [\(error)]")
            }
            if let exception = task.exception {
                print("failed: [\(exception)]")
            }
            if (task.error == nil && task.exception == nil) {
                dispatch_async( dispatch_get_main_queue()) {
                    let result = task.result!
                    let json = JSON(data: result.payload as NSData!)
                    completion( thingName, json )
                }
            }
            return nil
        }
    }
    func statusThingShadowCallback( thingName: String, json: JSON ) -> Void {
//        print("\(thingName): \(json)")
        if let tmpIntTemp = json["state"]["desired"]["intTemp"].int {
            interiorTemperature = tmpIntTemp
            interiorLabel.text = String(interiorTemperature)
        }
        if let tmpExtTemp = json["state"]["desired"]["extTemp"].int {
            exteriorTemperature = tmpExtTemp
            exteriorLabel.text = String(exteriorTemperature)
        }
        if let tmpState = json["state"]["desired"]["curState"].string {
            currentRunningState = tmpState
            switch(currentRunningState)
            {
                case "stopped":
                    interiorLabel.textColor = UIColor(red:0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case "heating":
                    interiorLabel.textColor = UIColor(red:1.0, green: 0.0, blue: 0.0, alpha: 1.0)
                case "cooling":
                    interiorLabel.textColor = UIColor(red:0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                default:
                    interiorLabel.textColor = UIColor(red:0.0, green: 0.0, blue: 0.0, alpha: 1.0)
            }
        }
    }
    func controlThingShadowCallback( thingName: String, json: JSON ) -> Void {
//        print("\(thingName): \(json)")
        if let tmpSetpoint = json["state"]["desired"]["setPoint"].int {
            currentSetpoint = tmpSetpoint
            setpointStepper.value=Double(currentSetpoint)
            setpointLabel.text = String(currentSetpoint)
        }
        if let tmpEnabled = json["state"]["desired"]["enabled"].bool {
            currentlyEnabled = tmpEnabled
            statusSwitch.on = currentlyEnabled
        }
    }
    func getThingStates() {
        getThingState(statusThingName, completion: statusThingShadowCallback)
        getThingState(controlThingName, completion: controlThingShadowCallback)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        // Initialize the setpoint stepper
        //
        setpointStepper.wraps=false
        setpointStepper.maximumValue=90
        setpointStepper.minimumValue=50
        setpointStepper.value=70
        //
        // Initialize the temperature and setpoint labels
        //
        interiorLabel.text="60"
        exteriorLabel.text="45"
        setpointLabel.text=setpointStepper.value.description
        //
        // Initialize the status switch
        //
        statusSwitch.on=true

        pollingTimer = NSTimer.scheduledTimerWithTimeInterval( 0.5, target: self, selector: "getThingStates", userInfo: nil, repeats: true )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

