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

##1. Setup Cognito

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool.

1. Open `CognitoSyncDemo.xcworkspace`.

1. Open `Constants.swift` and update the following lines with the appropriate constants:

    static let COGNITO_REGIONTYPE = AWSRegionType.Unknown // e.g. AWSRegionType.USEast1
    static let COGNITO_IDENTITY_POOL_ID = "YourCognitoIdentityPoolId"


1. Configure one (or more) of the following external providers and then build and run the sample app.

##2. Setup Facebook App
1. Sign up for the Facebook developer program at [developers.facebook.com](https://developers.facebook.com/)

1. Visit the guide [Getting Started with the Facebook SDK for iOS](https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/) and follow the instructions to **Create a Facebook App**. Make note of your `App ID`. You'll use it in configuring the sample. The other steps in this guide will be useful with your future Facebook Apps, but are not necessary for this sample. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.

1. In Xcode, update *FACEBOOK_APP_ID* with your app id and *FACEBOOK_DISPLAY_NAME* with your app name under the Information Property List.

1. In Xcode, update the `URL Types` `Facebook URL Handler` `URL Schemes` using the form `fb#########`, where ######### is `APP ID`.

##3. Setup Amazon App
1. Visit Amazon [Getting Started for iOS](http://login.amazon.com/ios) guide and follow the instructions to **Register a New Application**. Make sure to take note of your `App ID`. You'll use it in later steps. The other steps in this guide will be useful with your future Login with Amazon apps, but will not be necessary for this sample.

1. Under **Label** give the key a meaningful name.

1. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.  

1. Make sure to click **Get API Key Value** after creating your API key. This value is used in configuring the sample.  

1. In Xcode, enter just your Amazon API key under APIKey in the Information Property List

##4. Setup Google App
1. Visit the [Quick start for iOS](https://developers.google.com/+/quickstart/ios) guide and follow the instructions to **Enable the Google+ API**. Make sure to take note of your `Client ID` as this will be used in later steps. The other steps in this guide will be useful with your future Google+ Apps, but will not be necessary for this sample.

1. Under **Application type** select **Installed application**.

1. Under **Installed application type**, select **iOS**.

1. Enter the following as your **Bundle ID**: `com.amazon.aws.CognitoSyncDemo`.  

1. Copy the **Client ID** you generated with Google and update the following line in the `Constants.swift`:

	    static let GOOGLE_CLIENT_ID = "ENTER_CLIENT_ID"

##5. Setup Twitter/Digits App
1. Install [Fabric](https://fabric.io/)

1. Follow the tutorial and add the API_KEY, CONSUMER_KEY, and CONSUMER_SECRET under Fabric in the Information Property List

##6. Setup Developer Authenticated identities
1. Setup the [server side application](https://github.com/awslabs/amazon-cognito-developer-authentication-sample) before setting up client side configuration.
1. Open the `Constants.swift` file and update the following constants
	1. Update `DeveloperAuthAppName` to the App Name you have setup in the server side application.
	1. Update `DeveloperAuthEndpoint` to the URL of the server side application.
	1. Update `DeveloperAuthProviderName` to the developer provider name you have set in the [Amazon Cognito Console](https://console.aws.amazon.com/cognito/).
