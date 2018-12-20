# The Amazon IoT Sample

This sample demonstrates use of the AWS IoT APIs to securely publish to and subscribe from an MQTT topic.  It uses Cognito authentication in conjunction with AWS IoT to create an identity (client certificate and private key) and store it in the iOS keychain.  This identity is then used to authenticate to AWS IoT.  Once a connection to the AWS IoT platform has been established, the application can operate in either the publish or subscribe role; the data format is a single floating point number in the range of 1-50.  A configuration tab is provided allowing the user to select the name of the MQTT topic being published to or subscribed from, or to delete the identity.  This application also supports the use of a pre-existing identity.

## Requirements

* Xcode 9.2 and later
* iOS 9 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, change the current directory to the one with your **Podfile** in it and run the following command:

		pod install

1. This sample requires Cognito to authorize to AWS IoT in order to create a device certificate. Use Amazon Cognito to create a new identity pool:
	1. In the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/), press the `Manage Federated Identities` button and on the resulting page press the `Create new identity pool` button.
	1. Give your identity pool a name and ensure that `Enable access to unauthenticated identities` under the `Unauthenticated identities` section is checked.  This allows the sample application to assume the unauthenticated role associated with this identity pool.  Press the `Create Pool` button to create your identity pool.

		**Important**: see note below on unauthenticated user access.

	1. As part of creating the identity pool, Cognito will setup two roles in [Identity and Access Management (IAM)](https://console.aws.amazon.com/iam/home#roles).  These will be named something similar to: `Cognito_PoolNameAuth_Role` and `Cognito_PoolNameUnauth_Role`.  You can view them by pressing the `View Details` button.  Now press the `Allow` button to create the roles.
	1. Save the `Identity pool ID` value that shows up in red in the "Getting started with Amazon Cognito" page, it should look similar to: `us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" and note the region that is being used.  These will be used in the application code later.
    1. Now we will attach a policy to the unauthenticated role which has permissions to access the required AWS IoT APIs.  This is done by first creating an IAM Policy in the [IAM Console](https://console.aws.amazon.com/iam/home#roles) and then attaching it to the unauthenticated role.  Search for "pubsub" and click on the link for the unauth role.  Click on the "Add inline policy" button and add the following example policy which can be used with the sample application.  This policy allows the application to create a new certificate (including private key) as well as attach an existing policy to a certificate.

        ```
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": [
                "iot:AttachPrincipalPolicy",
                "iot:CreateKeysAndCertificate",
                "iot:CreateCertificateFromCsr"
              ],
              "Resource": [
                "*"
              ]
            }
          ]
        }
        ```

        More information on AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).  More information on AWS IoT policies can be found [here](http://docs.aws.amazon.com/iot/latest/developerguide/authorization.html).

        **Note**: to keep this example simple it makes use of unauthenticated users in the identity pool.  This can be used for getting started and prototypes but unauthenticated users should typically only be given read-only permissions if used in production applications.  More information on Cognito identity pools including the Cognito developer guide can be found [here](http://aws.amazon.com/cognito/).

1. Note that the application does not actually create the AWS IoT policy itself, rather it relies on a policy to already be created in AWS IoT and then makes a call to attach that policy to the newly created certificate.  To create a policy in AWS IoT,
    1. Navigate to the [AWS IoT Console](https://console.aws.amazon.com/iot/home) and press the `Get Started` button.  On the resulting page click on `Secure` on the side panel and the click on `Policies`.
    1. Click on `Create a Policy`
    1. Give the policy a name.  Note this name as this is the string you will use in the application when making the attach policy API call.
    1. The policy should be created to allow connecting to AWS IoT as well as allowing publishing, subscribing and receiving messages on whatever topics you will use in the sample application.  Below is an example policy.  This policy allows access to all topics under your AWS IoT account.   To scope this policy down to specific topics specify them explicitly as ARNs in the resource section: `"Resource": "arn:aws:iot:<REGION>:<ACCOUNT ID>:topic/mytopic/mysubtopic"`.  Note that the first `topic` is an ARN specifer so this example actually specifies the topic `mytopic/mysubtopic`.
    1. To add this policy, click on `Advanced Mode` and replace the default policy with the following text and then click the `Create` button.

        ```
        {
          "Version": "2012-10-17",
          "Statement": [
            {
              "Effect": "Allow",
              "Action": "iot:Connect",
              "Resource": "*"
            },
            {
              "Effect": "Allow",
              "Action": [
                "iot:Publish",
                "iot:Subscribe",
                "iot:Receive"
              ],
              "Resource": "*"
            }
          ]
        }
        ```

1. Open `IoTSampleSwift.xcworkspace`.

1. Open `awsconfiguration.json` and update the Cognito Identity Pool ID (from the value you saved above) and Cognito region for Cognito Identity Pool ID (for example us-east-1).

  ```json
  "CredentialsProvider": {
    "CognitoIdentity": {
      "Default": {
          "PoolId": "CHANGE_ME",
          "Region": "CHANGE_ME"
      }
    }
  }
  ```

1. Open `Constants.swift` and update the following lines with the appropriate constants:

	```swift
	let CertificateSigningRequestCommonName = "IoTSampleSwift Application"
	let CertificateSigningRequestCountryName = "Your Country"
	let CertificateSigningRequestOrganizationName = "Your Organization"
	let CertificateSigningRequestOrganizationalUnitName = "Your Organizational Unit"
	let PolicyName = "YourPolicyName"

	let AwsRegion = AWSRegionType.Unknown
	let IOT_ENDPOINT = "https://xxxxxxxxxx.iot.<region>.amazonaws.com" // make sure to include "https://" prefix
	```

1. Drop the awsiot-identity.p12 file (located in the same directory as your project workspace file into the 'Supporting Files' folder of the project.

1. Build and run the sample app on two different simulators or devices.  After you connect then changes in one devices publish panel will show up in the other devices subscribe panel.

1. The sample application will allow you to connect to the AWS IoT platform, and then publish or subscribe to a topic using MQTT.  You can configure the topic name under the 'Configuration' tab; it's set to 'slider' by default (only when you are disconnected).  You can use another instance of this application so that one instance publishes while the other subscribes, or you can use the MQTT client in the [Amazon AWS IoT console](https://console.aws.amazon.com/iot/) to interact with your application.

1. You can also configure the sample application to use an existing AWS IoT identity.  To do this, create a certificate and private key in the [Amazon AWS IoT console](https://console.aws.amazon.com/iot/) and associate it with a policy which allows access to 'iot:\*'.  Use the following command to create a PKCS #12 archive from the certificate and private key (NOTE: the filename must use the .p12 suffix):

```sh
openssl pkcs12 -export -in certificate.pem.crt -inkey private.pem.key -out awsiot-identity.p12
```

Drop the PKCS #12 archive you just created (named awsiot-identity.p12 in this example) in the 'Supporting Files' folder of the project, and when prompted by XCode, select all targets you want to import the identity into.  Build and run the application, and it will use this identity rather than creating one dynamically.  Note that when using your own certificate and private key, the "Delete" option under the "Configuration" tab only deletes them from the keychain; they remain in the application itself and will be re-added into the keychain the next time you connect.
