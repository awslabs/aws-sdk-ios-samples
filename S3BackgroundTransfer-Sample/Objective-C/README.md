# The Amazon S3 Background Transfer Sample

This sample demonstrates how to use `AWSS3PreSignedURLBuilder` to download / upload files in background.

## Requirements

* Xcode 6 and later
* iOS 7 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods

1. To install the AWS Mobile SDK for iOS, simply add the following line to your **Podfile**:

		pod "AWSiOSSDKv2"

	Then run the following command:
	
		pod install

1. Create an Amazon S3 bucket. (For details on creating a bucket in the Amazon S3 console, see [Create a Bucket](http://docs.aws.amazon.com/AmazonS3/latest/gsg/CreatingABucket.html).)

1. Upload a image in the bucket. Open `Constants.m` or `Constants.swift` and update the following lines with the appropriate constants:

	OBJECTIVE-C

		NSString *const S3BucketName = @"YourS3BucketName";
		NSString *const S3DownloadKeyName = @"YourDownloadKeyName";
		
	SWIFT

		let S3BucketName: String = "YourS3BucketName"
		let S3DownloadKeyName: String = "YourDownloadKeyName"

1. In the [Amazon Cognito console](https://console.aws.amazon.com/cognito/), use Amazon Cognito to create a new identity pool. Obtain the `AccountID`, `PoolID`, and `RoleUnauth` constants. Make sure the [role](https://console.aws.amazon.com/iam/home?region=us-east-1#roles) has full permissions for the bucket you created.

1. Open `S3BackgroundTransferSampleObjC.xcworkspace` or `S3BackgroundTransferSampleSwift.xcworkspace`.

1. Open `Constants.m` or `Constant.swift` and update the following lines with the appropriate constants:

	OBJECTIVE-C

	    NSString *const AWSAccountID = @"YourAccountID";
	    NSString *const CognitoPoolID = @"YourPoolID";
	    NSString *const CognitoRoleUnauth = @"YourRoleUnauth";
	    
	SWIFT

	    let AWSAccountID: String = "YourAccountID"
		let CognitoPoolID: String = "YourPoolID"
		let CognitoRoleUnauth: String? = "YourRoleUnauth"

1. Build and run the sample app.