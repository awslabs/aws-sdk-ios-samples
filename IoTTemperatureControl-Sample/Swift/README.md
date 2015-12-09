# The Amazon IoT Temperature Control Sample

This sample demonstrates use of the AWS IoT APIs to interact with device shadows.  It works in conjunction with the Temperature Control Example Program in the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

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

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `PoolID` constant. Make sure the [role](https://console.aws.amazon.com/iam/home?region=us-east-1#roles) has full permissions to access the AWS IoT APIs, as shown in this example:

```sh
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iot:*"
            ],
            "Resource": "*"
       }
    ]
}
```

1. Open `IoTTemperatureControlSample.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

```c
let AwsRegion = AWSRegionType.Unknown
let CognitoIdentityPoolId = "YourCognitoIdentityPoolId"
```

1. Install the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

1. Follow the instructions in the AWS IoT JavaScript SDK for Embedded Devices to install depenedencies for the temperature-control example application.

1. Start the AWS IoT JavaScript SDK for Embedded Devices temperature-control example application using '--test-mode=2' to simulate a temperature control device.

1. Build and run the sample app.
