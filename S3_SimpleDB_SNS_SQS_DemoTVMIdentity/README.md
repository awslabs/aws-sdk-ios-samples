## Running the S3_SimpleDB_SNS_SQS_DemoTVMIdentity Sample

This sample demonstrates interaction with a [Token Vending Machine](http://aws.amazon.com/articles/4611615499399490) where a username/password combination is required. The user is expected to register with the App first by connecting to an external website. In this sample the the website is a specific page on the Token Vending Machine. After registering, the user would be able to start the App by logging in.

It is assumed that you were able to run the S3_SimpleDB_SNS_SQS_Demo sample and that you are currently running an [Identity](http://aws.amazon.com/code/7351543942956566) version of the TVM, token vending machine.
 

1.  Open the `S3_SimpleDB_SNS_SQS_DemoTVMIdentity/AWSiOSDemoTVMIdentity.xcodeproj` project file in Xcode.
2.  Configure the sample with your Token Vending Machine credentials:
	1.  Open the `Constants.h` file.
	2.  Modify the `TOKEN_VENDING_MACHINE_URL` with the DNS domain name where your Token Vending Machine is running (ex: tvm.elasticbeanstalk.com).
	3.  Modify the `USE_SSL` to YES or NO based on whether your Token Vending Machine is running SSL or not.
	4.  Modify the `APP_NAME` with the name you configured your Token Vending Machine with (ex: MyMobileAppName).
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to `AWSiOSDemoTVMIdentity`
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the following frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSS3.framework
		*  AWSSimpleDB.framework
		*  AWSSQS.framework
		*  AWSSNS.framework
4.  Run the project.
