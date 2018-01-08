# The Amazon IoT Temperature Control Sample

This sample demonstrates use of the AWS IoT MQTT device shadow APIs over a WebSocket.  It works in conjunction with the Temperature Control Example Program in the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

## Requirements

* Xcode 7 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, change the current directory to the one with your **Podfile** in it and run the following command:

		pod install

1. This sample requires Cognito to authorize to AWS IoT in order to create a device certificate. Use Amazon Cognito to create a new identity pool:
	1. In the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/), press the `Manage Federated Identities` button and on the resulting page press the `Create new identity pool` button.
	1. Give your identity pool a name and ensure that `Enable access to unauthenticated identities` under the `Unauthenticated identities` section is checked.  This allows the sample application to assume the unauthenticated role associated with this identity pool.  Press the `Create Pool` button to create your identity pool.

		**Important**: See the note below on unauthenticated user access.

	1. As part of creating the identity pool, Cognito will setup two roles in [Identity and Access Management (IAM)](https://console.aws.amazon.com/iam/home#roles).  These will be named something similar to: `Cognito_IoTSampleAuth_Role` and `Cognito_IoTSampleUnauth_Role`.  You can view them by pressing the `View Details` button.  Now press the `Allow` button to create the roles.
	1. Save the `Identity pool ID` value that shows up in red in the "Getting started with Amazon Cognito" page, it should look similar to: `us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" and note the region that is being used.  These will be used in the application code later.
    1. Now we will attach a policy to the unauthenticated role which has permissions to access the required AWS IoT APIs.  This is done by attaching an IAM Policy to the unauthenticated role in the [IAM Console](https://console.aws.amazon.com/iam/home#roles). First, search for the unauth role that you created in step 3 above (named something similar to `Cognito_IoTSampleUnauth_Role`) and select its hyperlink.  In the resulting "Summary" page press the `Attach Policy` button in the "Permissions" tab.
	1. Search for "iot" and check the box next to the policy named `AWSIoTFullAccess` and then press the `Attach Policy` button.  This policy allows the application to perform all operations on the Amazon IoT service.

        More information on AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).  More information on AWS IoT policies can be found [here](http://docs.aws.amazon.com/iot/latest/developerguide/authorization.html).

        **Note**: To keep this example simple it makes use of unauthenticated users in the identity pool.  This can be used for getting started and prototypes but unauthenticated users should typically only be given read-only permissions if used in production applications.  More information on Cognito identity pools including the Cognito developer guide can be found [here](http://aws.amazon.com/cognito/).

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

1. Open `IoTTemperatureControlSample.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

	```c
	let AwsRegion = AWSRegionType.Unknown // e.g. AWSRegionType.USEast1
	let CognitoIdentityPoolId = "YourCognitoIdentityPoolId"
        let IOT_ENDPOINT = "https://xxxxxxxxxx.iot.<region>.amazonaws.com"
	```
1. Install the [AWS IoT JavaScript SDK for Embedded Devices](https://github.com/aws/aws-iot-device-sdk-js).

1. Follow the instructions in the AWS IoT JavaScript SDK for Embedded Devices to install dependencies for the temperature-control example application.

1. Start the AWS IoT JavaScript SDK for Embedded Devices temperature-control example application using '--test-mode=2' to simulate a temperature control device.

1. Build and run the sample app.
