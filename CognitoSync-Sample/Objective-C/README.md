# The Amazon Cognito Sync Sample

This sample demonstrates how to create unique identities for users of your app using public login providers such as Amazon, Facebook, and Google as well as developer authenticated identities, and store app data for these users in the Amazon Cognito sync store.

## Requirements

* Xcode 6 and later
* iOS 7 and later

## Using the Sample

###1. Setup CocoaPods
1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod 'AWSCognito'
		pod 'Facebook-iOS-SDK' 

	Then run the following command:
	
		pod install

###2. Setup Facebook App (Optional)
1. Sign up for the Facebook developer program at [developers.facebook.com](https://developers.facebook.com/)

1. Visit the guide [Getting Started with the Facebook SDK for iOS](https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/) and follow the instructions to **Create a Facebook App**. Make note of your `App ID`. You'll use it in configuring the sample. The other steps in this guide will be useful with your future Facebook Apps, but are not necessary for this sample. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.

1. In Xcode, update *FacebookAppID* with your app id and *FacebookDisplayName* with your app name under **Custom iOS Target Properties**.

1. In Xcode, update the `URL Types` `Facebook URL Handler` `URL Schemes` using the form `fb#########`, ######### is `APP ID`.
**NOTE: the preceding 'fb' before the numeric App ID is REQUIRED.**

###3. Setup Amazon App (Optional)
1. Visit Amazon [Getting Started for iOS](http://login.amazon.com/ios) guide and follow the instructions to **Register a New Application**. Make sure to take note of your `App ID`. You'll use it in later steps. The other steps in this guide will be useful with your future Login with Amazon apps, but will not be necessary for this sample.  

1. Under **Label** give the key a meaningful name.

1. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.  

1. Make sure to click **Get API Key Value** after creating your API key. This value is used in configuring the sample.  

1. In Xcode, enter just your Amazon API key under APIKey in Custom iOS Target Properties

###4. Setup Google App (Optional)
1. Google App cannot work together with Amazon App at same time, due to known bug. We are working with the teams involved to address this issue. 

1. Visit the [Quick start for iOS](https://developers.google.com/+/quickstart/ios) guide and follow the instructions to **Enable the Google+ API**. Make sure to take note of your `Client ID` as this will be used in later steps. The other steps in this guide will be useful with your future Google+ Apps, but will not be necessary for this sample. 

1. Under **Application type** select **Installed application**. 

1. Under **Installed application type**, select **iOS**.

1. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.  

1. Disable Login with Amazon by removing `LoginWithAmazon.framework` from the project.

1. Copy the **Client ID** you generated with Google and update following line in `Constants.m`:

	    NSString *const GoogleClientID = @"GoogleClientID";

1. In Xcode, remove `LoginWithAmazon.framework` in your project.

1. Open `Podfile` and remove # of following line:
		
		#pod 'google-plus-ios-sdk'
Remove `Podfile.lock`. Then run the following command:
	
		pod install

###5. Setup Twitter/Digits App (Optional)
1. Install [Fabric](https://fabric.io/)

1. Use `Fabric.App` to add the Fabric and TwitterKit SDKs into `CognitoSyncDemo.xcodeproj`


###6. Setup Developer Authenticated Identities (Optional)
1. Setup the [server side application](https://github.com/awslabs/amazon-cognito-developer-authentication-sample) before setting up client side configuration.
1. Open the `Constant.m` file and update the following constants
	1. Update `DeveloperAuthAppName` to the App Name you have setup in the server side application.
	1. Update `DeveloperAuthEndpoint` to the URL of the server side application.
	1. Update `DeveloperAuthProviderName` to the developer provider name you have set in the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/).

###7. Setup Cognito
1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool.

1. Open `CognitoSyncDemo.xcworkspace`.

1. Open `Constants.m` and update the following lines with the appropriate constants:
	
        AWSRegionType const CognitoRegionType = AWSRegionUnknown; // e.g. AWSRegionUSEast1
        NSString *const CognitoIdentityPoolId = @"YourCognitoIdentityPoolId";

1. Build and run the sample app.
