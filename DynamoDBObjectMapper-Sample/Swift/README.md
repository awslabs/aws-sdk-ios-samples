# The Amazon DynamoDB Object Mapper Sample (Swift)

This sample demonstrates the DynamoDB object mapper found in the AWS SDK for iOS.

## Requirements

* Xcode 8 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

        source 'https://github.com/CocoaPods/Specs.git'
        
        platform :ios, '8.0'
        use_frameworks!
        
        pod 'AWSDynamoDB', '~> 2.5.0'

	Then run the following command:
	
		pod install

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `AccountID`, `PoolID`, and `RoleUnauth` constants. Make sure the [role](https://console.aws.amazon.com/iam/home?region=us-east-1#roles) has full permissions for the sample table.

1. Open `DynamoDBSampleSwift.xcworkspace`.

1. Open `Info.plist` and update the following lines with the appropriate constants:

        AWS --> CredentialsProvider --> CognitoIdentity --> Default --> Region      // eg. USEast1
        AWS --> CredentialsProvider --> CognitoIdentity --> Default --> PoolId
        AWS --> DynamoDB --> Default --> Region                                     // eg. USEast1
        AWS --> DynamoDBObjectMapper --> Default --> Region                         // eg. USEast1

1. Build and run the sample app.
