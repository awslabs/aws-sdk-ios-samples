# The Amazon Lex Sample

This sample demonstrates how to use Amazon Lex interaction client library on iOS. This application uses AWS Cognito for authentication with Amazon Lex.

## Requirements

* Xcode 9.2 and later
* iOS 9 and later

## Using the Sample
 
1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, change the current directory to the one with your **Podfile** in it and run the following command:

		pod install

1. This sample requires Cognito to authorize to Amazon Lex to post content.  Use Amazon Cognito to create a new identity pool:
    1. In the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/), press the `Manage Federated Identities` button and on the resulting page press the `Create new identity pool` button.
    1. Give your identity pool a name and ensure that `Enable access to unauthenticated identities` under the `Unauthenticated identities` section is checked.  This allows the sample application to assume the unauthenticated role associated with this identity pool.  Press the `Create Pool` button to create your identity pool.

        **Important**: see note below on unauthenticated user access.

    1. As part of creating the identity pool, Cognito will setup two roles in [Identity and Access Management (IAM)](https://console.aws.amazon.com/iam/home#roles).  These will be named something similar to: `Cognito_PoolNameAuth_Role` and `Cognito_PoolNameUnauth_Role`. You can view them by pressing the `View Details` button. Now press the `Allow` button to create the roles.
    1. Save the `Identity pool ID` value that shows up in red in the "Getting started with Amazon Cognito" page, it should look similar to: `us-east-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` and note the region that is being used.  These will be used in the application code later.
    1. Now we will attach a policy to the unauthenticated role which has permissions to access the required Amazon Lex API.  This is done by attaching an IAM Policy to the unauthenticated role in the [IAM Console](https://console.aws.amazon.com/iam/home#roles).  First, search for the unauth role that you created in step 3 above (named something similar to `Cognito_PoolNameUnauth_Role`) and select its hyperlink.  In the resulting "Summary" page press the `Attach Policy` button in the "Permissions" tab.
    1. Search for "lex" and check the box next to the policy named `AmazonLexRunBotsOnly` and then press the `Attach Policy` button.  This policy allows the application access to Amazon Lex conversational APIs.
 
        More information on AWS IAM roles and policies can be found [here](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_manage.html).  More information on Amazon Lex policies can be found [here](http://docs.aws.amazon.com/lex/latest/dg/access-control-managing-permissions.html).

		**Note**: to keep this example simple it makes use of unauthenticated users in the identity pool.  This can be used for getting started and prototypes but unauthenticated users should typically only be given read-only permissions in production applications.  More information on Cognito identity pools including the Cognito developer guide can be found [here](http://aws.amazon.com/cognito/).
1. Use the [Amazon Lex console](https://console.aws.amazon.com/lex/home) to configure a bot that interacts with your mobile app features. To learn more, see [Amazon Lex Developer Guide](https://docs.aws.amazon.com/lex/latest/dg/what-is.html). For a quickstart, see [Getting Started](https://alpha-docs-aws.amazon.com/lex/latest/dg/getting-started.html).

1. Open `LexSwift.xcworkspace/`.

1. Open `awsconfiguration.json` and update the values for Cognito Identity Pool ID (from the value you saved above) and Cognito region for Cognito Identity Pool ID (for example us-east-1).

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
    let LexRegion = AWSRegionType.Unknown                       // Change this to your Lex region (most are currently AWSRegionType.USEast1)
    let BotName = "BotName"                                     // Put your bot name here
    let BotAlias = "$LATEST"                                    // You can leave this if you always want to use the latest version of your bot or put the version
	```

1. Build and run the sample app.
