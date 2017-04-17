# The Amazon IoT Sample

This sample demonstrates use of the AWS IoT APIs to securely publish to and subscribe from an MQTT topic.  It uses Cognito authentication in conjunction with AWS IoT to create an identity (client certificate and private key) and store it in the iOS keychain.  This identity is then used to authenticate to AWS IoT.  Once a connection to the AWS IoT platform has been established, the application can operate in either the publish or subscribe role; the data format is a single floating point number in the range of 1-50.  A configuration tab is provided allowing the user to select the name of the MQTT topic being published to or subscribed from, or to delete the identity.  This application also supports the use of a pre-existing identity.

## Requirements

* Xcode 8 and later
* iOS 9 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod 'AWSIoT'

	Then run the following command:
	
		pod install

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `PoolID` constant.  Make sure that the policy attached to the [unauthenticated role](https://console.aws.amazon.com/iam/home?#roles) has permissions to access the required AWS IoT APIs.  More information about AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).

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

1. The sample application will allow you to connect to the AWS IoT platform, and then publish or subscribe to a topic using MQTT.  You can configure the topic name under the 'Configuration' tab; it's set to 'slider' by default.  You can use another instance of this application so that one instance publishes while the other subscribes, or you can use the MQTT client in the [Amazon AWS IoT console](https://console.aws.amazon.com/iot/) to interact with your application.

1. You can also configure the sample application to use an existing AWS IoT identity.  To do this, create a certificate and private key in the [Amazon AWS IoT console](https://console.aws.amazon.com/iot/) and associate it with a policy which allows access to 'iot:\*'.  Use the following command to create a PKCS #12 archive from the certificate and private key (NOTE: the filename must use the .p12 suffix):

```sh
openssl pkcs12 -export -in certificate.pem.crt -inkey private.pem.key -out awsiot-identity.p12
```

Drop the PKCS #12 archive you just created (named awsiot-identity.p12 in this example) in the 'Supporting Files' folder of the project, and when prompted by XCode, select all targets you want to import the identity into.  Build and run the application, and it will use this identity rather than creating one dynamically.  Note that when using your own certificate and private key, the "Delete" option under the "Configuration" tab only deletes them from the keychain; they remain in the application itself and will be re-added into the keychain the next time you connect.
