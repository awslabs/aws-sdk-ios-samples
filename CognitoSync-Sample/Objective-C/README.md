# The Amazon Cognito Sync Sample

This sample demonstrates how to create unique identities for users of your app using public login providers such as Amazon, Facebook, and Google as well as developer authenticated identities, and store app data for these users in the Amazon Cognito sync store.

## Requirements

* Xcode 7 and later
* iOS 8 and later

## Using the Sample

###Setup CocoaPods
1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod 'AWSCognito'
		pod 'Facebook-iOS-SDK' 

	Then run the following command:
	
		pod install

###Setup Developer Authenticated Identities (Optional)

1. Setup the [server side application](https://github.com/awslabs/amazon-cognito-developer-authentication-sample) before setting up client side configuration.
1. Open the `Constant.m` file and update the following constants
	1. Update `DeveloperAuthAppName` to the App Name you have setup in the server side application.
	1. Update `DeveloperAuthEndpoint` to the URL of the server side application.
	1. Update `DeveloperAuthProviderName` to the developer provider name you have set in the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/).

###Setup Cognito
1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool.

1. Open `CognitoSyncDemo.xcworkspace`.

1. Open `Constants.m` and update the following lines with the appropriate constants:
	
        AWSRegionType const CognitoRegionType = AWSRegionUnknown; // e.g. AWSRegionUSEast1
        NSString *const CognitoIdentityPoolId = @"YourCognitoIdentityPoolId";

1. Build and run the sample app.
