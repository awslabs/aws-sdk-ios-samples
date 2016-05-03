# The Amazon DynamoDB Object Mapper Sample

This sample demonstrates the DynamoDB object mapper found in the AWS SDK for iOS.

## Requirements

* Xcode 7 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		source 'https://github.com/CocoaPods/Specs.git'

        platform :ios, '8.0'
        use_frameworks!

        pod 'AWSDynamoDB', '~> 2.4.1'

1. Then run the following command:
        	
        pod install

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `PoolID` constant. Make sure the [role](https://console.aws.amazon.com/iam/home?region=us-east-1#roles) has full permissions for the sample table.

1. Open `DynamoDBSample.xcworkspace`.

1. Open `Constants.m` and update the following line (Optional):

        NSString *const AWSSampleDynamoDBTableName = @"DynamoDB-OM-Sample";

1. Open `Info.plist` and update the following lines with the appropriate constants:
    
        AWS --> CredentialsProvider --> CognitoIdentity --> Default --> Region      // e.g. USEast1
        AWS --> CredentialsProvider --> CognitoIdentity --> Default --> PoolId      // e.g. us-east-1:12345678-1234-1234-1234-123456789abc
        AWS --> DynamoDB --> Default --> Region                                     // e.g. USEast1
        AWS --> DynamoDBObjectMapper --> Default --> Region                         // e.g. USEast1

1. Build and run the sample app.
