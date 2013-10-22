## Running the DynamoDB_WIF_UserPreference

This is a sample mobile application that demonstrates how to use Amazon DynamoDB to store a user preferences by using Web Identity Federation.

For a more detailed description of the code, please visit this [online article](http://aws.amazon.com/articles/7439603059327617).

1.  Open the `DynamoDB_WIF_UserPreference/UserPreference.xcodeproj` project file in Xcode.
2.  Configure the sample with your AWS security credentials or WIF:
	1. If using AWS security credentials:
		1.  Open the `Constants.h` file.
		2.  Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.
	2. If using Web Identity Federation(WIF), see the [README](../S3_WIF_PersonalFileStore/README.md) file under `/S3_WIF_PersonalFileStore/`.
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to `UserPreference`
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the following frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSDynamoDB.framework
		*  AWSSecurityTokenService.framework
		*  ThirdParty (Which includes FacebookSDK.framework and login-with-amazon.)
4.  Run the project.
