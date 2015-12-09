# The Amazon IoT Sample

This sample demonstrates use of the AWS IoT APIs to securely publish to and subscribe from an MQTT topic.  It uses Cognito authentication in conjunction with AWS IoT to create an identity (client certificate and private key) and store it in the iOS keychain.  This identity is then used to authenticate to AWS IoT.  Once a connection to the AWS IoT platform has been established, the application can operate in either the publish or subscribe role; the data format is a single floating point number in the range of 1-50.  A configuration tab is provided allowing the user to select the name of the MQTT topic being published to or subscribed from, or to delete the identity.

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

1. In the [Amazon AWS IoT console](https://console.aws.amazon.com/iot/), create a policy with full permissions to access AWS IoT as shown in this example.  Select 'Create a Policy', fill in the 'Name' field, set 'Action' to 'iot:\*', set 'Resource' to '\*', and then click 'Create'.

1. Open `IoTSampleSwift.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

```c
let AwsRegion = AWSRegionType.Unknown
let CognitoIdentityPoolId = "YourCognitoIdentityPoolId"
let CertificateSigningRequestCommonName = "IoTSampleSwift Application"
let CertificateSigningRequestCountryName = "Your Country"
let CertificateSigningRequestOrganizationName = "Your Organization"
let CertificateSigningRequestOrganizationalUnitName = "Your Organizational Unit"
let PolicyName = "YourPolicyName"
```

1. Build and run the sample app.

1. The sample application will allow you to connect to the AWS IoT platform, and then publish or subscribe to a topic using MQTT.  You can configure the topic name under the 'Configuration' tab; it's set to 'slider' by default.  You can use another instance of this application so that one instance publishes while the other subscribes, or you can use another MQTT client such as [mosquitto](http://mosquitto.org/) to interact with your application.
