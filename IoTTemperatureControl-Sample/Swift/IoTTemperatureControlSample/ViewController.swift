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
    var currentSetpointStepValue: Double!;
    var statusThingOperationInProgress:  Bool = false;
    var controlThingOperationInProgress: Bool = false;
    weak var setupTimer: NSTimer?;

    var iotDataManager: AWSIoTDataManager!;
    
    func updateThingShadow( thingName: String, jsonData: JSON )
    {
        self.iotDataManager.publishString( jsonData.rawString(), onTopic: "$aws/things/\(thingName)/shadow/update", qoS:.MessageDeliveryAttemptedAtMostOnce);
    }

    @IBAction func statusSwitchChanged(sender: UISwitch) {
        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [ "setPoint": currentSetpoint, "enabled": sender.on]]])

        if (!controlThingOperationInProgress)
        {
            updateThingShadow( controlThingName, jsonData: controlJson )
            controlThingOperationInProgress = true
        }
        else
        {
            sender.on = !sender.on;    // cancel the operation
        }
    }
    
    @IBAction func setpointStepperTapped(sender: UIStepper) {
        //
        // Initialize the control JSON object
        //
        let controlJson = JSON(["state": ["desired": [ "setPoint": Int(sender.value), "enabled": currentlyEnabled]]])

        if (!controlThingOperationInProgress)
        {
            currentSetpoint = Int(setpointStepper.value)
            setpointLabel.text = String(currentSetpoint)
            updateThingShadow( controlThingName, jsonData: controlJson )
            controlThingOperationInProgress = true
        }
        else
        {
            sender.value = currentSetpointStepValue;    // cancel the operation
        }
    }
    
    func getThingState( thingName: String )
    {
        self.iotDataManager.publishString( "{ }", onTopic: "$aws/things/\(thingName)/shadow/get", qoS:.MessageDeliveryAttemptedAtMostOnce);
    }
    
    func updateStatus( interiorTemperature: Int?, exteriorTemperature: Int?, state: String? )
    {
        if let interiorTemperature = interiorTemperature {
            interiorLabel.text = String(interiorTemperature)
        }
        if let exteriorTemperature = exteriorTemperature {
            exteriorLabel.text = String(exteriorTemperature)
        }
        if let state = state {
            currentRunningState = state
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
    
    func updateControl( setPoint: Int?, enabled: Bool? )
    {
        if let setPoint = setPoint {
            setpointStepper.value=Double(setPoint)
            setpointLabel.text = String(setPoint)
            currentSetpointStepValue = setpointStepper.value;
        }
        if let enabled = enabled {
            statusSwitch.on = enabled
        }
    }
    func thingShadowDeltaCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            updateControl( json["state"]["setPoint"].int,
                enabled: json["state"]["enabled"].bool );
        }
        else   // thingName == statusThingName
        {
            updateStatus( json["state"]["intTemp"].int,
                exteriorTemperature: json["state"]["extTemp"].int,
                state: json["state"]["curState"].string );
        }
    }
    func thingShadowAcceptedCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            updateControl( json["state"]["desired"]["setPoint"].int,
                enabled: json["state"]["desired"]["enabled"].bool );
            controlThingOperationInProgress = false;
        }
        else   // thingName == statusThingName
        {
            updateStatus( json["state"]["desired"]["intTemp"].int,
                exteriorTemperature: json["state"]["desired"]["extTemp"].int,
                state: json["state"]["desired"]["curState"].string );
            statusThingOperationInProgress = false;
        }
    }
    func thingShadowRejectedCallback( thingName: String, json: JSON, payloadString: String ) -> Void {
        if (thingName == controlThingName)
        {
            controlThingOperationInProgress = false;
        }
        else   // thingName == statusThingName
        {
            statusThingOperationInProgress = false;
        }
        print("operation rejected on: \(thingName)")
    }
    func getThingStates() {
        getThingState(statusThingName)
        getThingState(controlThingName)
    }
    func dispatchSpecialTopic(thingName: String, payload: NSData, callback: ( String, JSON, String ) -> Void) {
        let stringValue = NSString(data: payload, encoding: NSUTF8StringEncoding)!
        
        print("received: \(stringValue)")
        let json = JSON(data: payload as NSData!)
        
        dispatch_async(dispatch_get_main_queue()) {
            callback( thingName, json, stringValue as String );
        }
    }
    func subscribeSpecialTopics() {
        let things = [String]( arrayLiteral: statusThingName, controlThingName );

        for thing in things
        {
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/update/accepted", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowAcceptedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/update/rejected", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowRejectedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/get/accepted", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowAcceptedCallback );
            })
            self.iotDataManager.subscribeToTopic("$aws/things/\(thing)/shadow/get/rejected", qoS: .MessageDeliveryAttemptedAtMostOnce, messageCallback: {
                (payload) ->Void in
                self.dispatchSpecialTopic( thing, payload: payload, callback: self.thingShadowRejectedCallback );
            })
        }
     }
    func mqttEventCallback( status: AWSIoTMQTTStatus )
    {
        dispatch_async( dispatch_get_main_queue()) {
            print("connection status = \(status.rawValue)")
            switch(status)
            {
            case .Connecting:
                print( "Connecting..." )
                
            case .Connected:
                print( "Connected" )
                
            case .Disconnected:
                print( "Disconnected" )
                
            case .ConnectionRefused:
                print( "Connection Refused" )
                
            case .ConnectionError:
                print( "Connection Error" )
                
            case .ProtocolError:
                print( "Protocol Error" )
                
            default:
                print("unknown state: \(status.rawValue)")
            }
        }
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
        currentSetpointStepValue = setpointStepper.value
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
        
        //
        // Init IOT
        //
        iotDataManager = AWSIoTDataManager.defaultIoTDataManager()
        
        #if DEMONSTRATE_LAST_WILL_AND_TESTAMENT
        //
        // Set a Last Will and Testament message in the MQTT configuration; other
        // clients can subscribe to this topic, and if this client disconnects from
        // from AWS IoT unexpectedly, they will receive the message defined here.
        // Note that this is optional; your application may not need to specify a
        // Last Will and Testament.
        //
        // To enable this code, add '-DDEMONSTRATE_LAST_WILL_AND_TESTAMENT' to
        // your project build flags in:
        //
        //    Build Settings -> Swift Compiler - Custom Flags -> Other Swift Flags
        //
        // IMPORTANT NOTE FOR SWIFT PROGRAMS: When specifying the Last Will and Testament
        // message in Swift, make sure to use the NSString data type; this object must
        // support the dataUsingEncoding selector, which is not available in Swift's
        // native String type.
        //
        let lwtTopic: NSString = "temperature-control-last-will-and-testament"
        let lwtMessage: NSString = "disconnected"
        self.iotDataManager.mqttConfiguration.lastWillAndTestament.topic = lwtTopic as String
        self.iotDataManager.mqttConfiguration.lastWillAndTestament.message = lwtMessage as String
        self.iotDataManager.mqttConfiguration.lastWillAndTestament.qos = .AtMostOnce
        #endif

        //
        // Connect via WebSocket
        //
        self.iotDataManager.connectUsingWebSocketWithClientId( NSUUID().UUIDString, cleanSession:true, statusCallback: mqttEventCallback)
            
        //
        // Wait a few seconds and then subscribe to the special thing shadow topics.
        //
        
        setupTimer = NSTimer.scheduledTimerWithTimeInterval( 2.5, target: self, selector: #selector(ViewController.subscribeSpecialTopics), userInfo: nil, repeats: false )
        
        //
        // Two seconds after subscribing to all the special topics, retrieve the current thing states.
        //
        NSTimer.scheduledTimerWithTimeInterval( 4.5, target: self, selector: #selector(ViewController.getThingStates), userInfo: nil, repeats: false )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

