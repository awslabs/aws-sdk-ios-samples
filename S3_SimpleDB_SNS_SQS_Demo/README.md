## Running the S3_SimpleDB_SNS_SQS_Demo

This is a sample mobile application that demonstrates how to make requests to AWS using the iOS SDK.

1.  Open the `AWSiOSDemo/AWSiOSDemo.xcodeproj` project file in Xcode.
2.  Configure the sample with your AWS security credentials:
	1.  Open the `Constants.h` file.
	2.  Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.  
		**DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.**
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to `AWSiOSDemo`
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the following frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSS3.framework
		*  AWSSimpleDB.framework
		*  AWSSQS.framework
		*  AWSSNS.framework
4.  Run the project.
