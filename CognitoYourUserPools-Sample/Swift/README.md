# The Amazon Cognito User Pools Sample

This sample demonstrates the Amazon Cognito Identity Provider found in the AWS Mobile SDK for iOS.

## Requirements

* Xcode 8 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

2. To install the AWS Mobile SDK for iOS run the following command in the directory containing this sample:

		pod install

3. Create an Amazon Cognito User Pool. Follow the 4 steps under **Creating your Cognito Identity user pool** in this [blog post](http://mobile.awsblog.com/post/TxGNH1AUKDRZDH/Announcing-Your-User-Pools-in-Amazon-Cognito).

4. Open `CognitoYourUserPoolsSample.xcworkspace`.

5. Open **Constants.swift**. Set **CognitoIdentityUserPoolRegion**, **CognitoIdentityUserPoolId**, **CognitoIdentityUserPoolAppClientId** and **CognitoIdentityUserPoolAppClientSecret** to the values obtained when you created your user pool.
```swift
		let CognitoIdentityUserPoolRegion: AWSRegionType = .Unknown
		let CognitoIdentityUserPoolId = "YOUR_USER_POOL_ID"
		let CognitoIdentityUserPoolAppClientId = "YOUR_APP_CLIENT_ID"
		let CognitoIdentityUserPoolAppClientSecret = "YOUR_APP_CLIENT_SECRET"
```

6. Build and run the sample app.

## Notes
The sample showcases how to display a UI that requires an authenticated user.  
If valid tokens don't exist, it implements the AWSCognitoIdentityInteractiveAuthenticationDelegate to display the sign-in UI and prompt the user to login.  
If you quit the app while signed in and restart it, it will remain signed in.  It also implements AWSCognitoIdentityRememberDevice to show how to remember devices
and AWSCognitoIdentityNewPasswordRequired to demonstrate how to prompt your end user to change their password during sign-in.
