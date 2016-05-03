# The Amazon Cognito Sync Sample

This sample demonstrates how to create unique identities for users of your app using public login providers such as Amazon, Facebook, and Google as well as developer authenticated identities, and store app data for these users in the Amazon Cognito sync store.

## Requirements

* Swift 2.0
* Xcode 7 and later
* iOS 8 and later

## Using the Sample

All the necessary frameworks are located within the podfile (except the Login with Amazon Framework which is provided in the project itself). If you have not installed CocoaPods, install [CocoaPods](http://cocoapods.org):

		sudo gem install cocoapods
		pod setup

All the necessary frameworks are already in the Podfile. Just run the following command:

		pod install

Some set up is required in order to be able to log-in using external providers. But only 1 is required to actually be able to run the app.

##Setup Cognito

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool.

1. Open `CognitoSyncDemo.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

        static let COGNITO_REGIONTYPE = AWSRegionType.Unknown // e.g. AWSRegionType.USEast1
        static let COGNITO_IDENTITY_POOL_ID = "YourCognitoIdentityPoolId"

1. Configure one (or more) of the following external providers and then build and run the sample app.

##Setup Developer Authenticated identities
1. Setup the [server side application](https://github.com/awslabs/amazon-cognito-developer-authentication-sample) before setting up client side configuration.
1. Open the `Constants.swift` file and update the following constants
	1. Update `DeveloperAuthAppName` to the App Name you have setup in the server side application.
	1. Update `DeveloperAuthEndpoint` to the URL of the server side application.
	1. Update `DeveloperAuthProviderName` to the developer provider name you have set in the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/).
