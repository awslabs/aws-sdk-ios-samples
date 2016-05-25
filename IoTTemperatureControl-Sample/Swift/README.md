# The Amazon IoT Temperature Control Sample

This sample demonstrates use of the AWS IoT MQTT device shadow APIs over a WebSocket.  It works in conjunction with the Temperature Control Example Program in the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

## Requirements

* Xcode 7 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod 'AWSIoT'

	Then run the following command:
	
		pod install

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `PoolID` constant.  Make sure that the policy attached to the [unauthenticated role](https://console.aws.amazon.com/iam/home?#roles) has permissions to access the required AWS IoT APIs.  More information about AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).

1. Open `IoTTemperatureControlSample.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

	```c
	let AwsRegion = AWSRegionType.Unknown // e.g. AWSRegionType.USEast1
	let CognitoIdentityPoolId = "YourCognitoIdentityPoolId"
	```
1. Install the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

1. Follow the instructions in the AWS IoT JavaScript SDK for Embedded Devices to install dependencies for the temperature-control example application.

1. Start the AWS IoT JavaScript SDK for Embedded Devices temperature-control example application using '--test-mode=2' to simulate a temperature control device.

1. Build and run the sample app.
