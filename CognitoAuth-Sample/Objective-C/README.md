# The Amazon Cognito Auth Sample

This sample demonstrates Amazon Cognito Auth found in the AWS Mobile SDK for iOS.  If you need to integrate with Amazon Cognito Your User Pools and don't want to implement your own UI for sign-up and sign-in, this SDK uses a hosted page to provide a UI.

## Requirements

* Xcode 8 and later
* iOS 9 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS run the following command in the directory containing this sample:
	
		pod install

1. Create an Amazon Cognito User Pool. Follow the 4 steps under **Creating your Cognito Identity user pool** in this [blog post] (http://mobile.awsblog.com/post/TxGNH1AUKDRZDH/Announcing-Your-User-Pools-in-Amazon-Cognito).
2. Configure App Integration for the App Client you created above
   1. Under **Enabled Identity Providers** check __Cognito User Pool__
   2. Under **Sign in and sign out URLs** specify `myapp://` for both the Callback URL(s) and Sign out URL(s)
   3. Under **OAuth2.0** Check __Authorization code grant__
   4. Under **Allowed OAuth Scopes** check __openid__
   5. Click __Save changes__
   6. Click __Choose domain__
   7. Enter a domain prefix for your auth endpoint and click __Create Domain__
   8. Optionally continue with __Customize UI__ to set a background image.

1. Open `CognitoAuthSample.xcworkspace`.
1. Right Click on `Info.plist` and `Open As->Source Code`
2. Search for __SETME__ and replace all of the values based on the setup you just did above.
1. Build and run the sample app.