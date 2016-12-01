# The Amazon Polly Sample

This sample demonstrates use of the Amazon Polly APIs to retrieve list of voices and generate speech using the given voice.  It uses Cognito authentication in conjunction with Amazon Polly in order to authenticate to the Amazon Polly service. The user is presented with a list of voices which is retrieved when the application loads.

## Requirements

* Xcode 8 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod 'AWSPolly'

	Then run the following command:

		pod install

1. This sample requires Cognito to authorize to Amazon Polly in order to access device shadows.  Use Amazon Cognito to create a new identity pool:
	1. In the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/), select `Create Identity Pool`.
	1. Ensure `Enable access to unauthenticated identities` is checked.  This allows the sample application to assume the unauthenticated role associated with this identity pool.

		**Important**: see note below on unauthenticated user access.

	1. Obtain the `PoolID` constant.  This will be used in the application.
	1. As part of creating the identity pool Cognito will setup two roles in [Identity and Access Management (IAM)](https://console.aws.amazon.com/iam/home#roles).  These will be named something similar to: `Cognito_PoolNameAuth_Role` and `Cognito_PoolNameUnauth_Role`.
	1. Now we will attach a policy to the unauthenticated role which has permissions to access the required Amazon Polly API.  This is done by first creating an IAM Policy in the [IAM Console](https://console.aws.amazon.com/iam/home#policies) and then attaching it to the unauthenticated role.  Below is an example policy which can be used with the sample application.  This policy allows the application to perform all operations on the Amazon Polly service.

		```
		{
		  "Version": "2012-10-17",
		  "Statement": [
			{
			  "Effect": "Allow",
			  "Action": [
				"polly:*"
			  ],
			  "Resource": [
				"*"
			  ]
			}
		  ]
		}
		```

		More information on AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).  More information on Amazon Polly policies can be found [here](http://docs.aws.amazon.com/polly/latest/dg/using-identity-based-policies.html).

		**Note**: to keep this example simple it makes use of unauthenticated users in the identity pool.  This can be used for getting started and prototypes but unauthenticated users should typically only be given read-only permissions in production applications.  More information on Cognito identity pools including the Cognito developer guide can be found [here](http://aws.amazon.com/cognito/).

1. Open `PollySample.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

	```c
	let AwsRegion = AWSRegionType.Unknown
	let CognitoIdentityPoolId = "YourCognitoIdentityPoolId"
	```

1. Build and run the sample app.

The app will automatically query Amazon Polly for the list of voices and synthesize text with the selected voice.
