## Running the S3_SimpleDB_SNS_SQS_DemoTVM Sample


This sample demonstrates interaction with the [Token Vending Machine](http://aws.amazon.com/articles/4611615499399490) without requiring an identity from the user.

It is assumed that you were able to run the S3_SimpleDB_SNS_SQS_Demo sample and that you are currently running the [Anonymous](http://aws.amazon.com/code/8872061742402990) version of the TVM, token vending machine.

1.  Open the `S3_SimpleDB_SNS_SQS_DemoTVM/AWSiOSDemoTVM.xcodeproj` project file in Xcode.
2.  Configure the sample with your Token Vending Machine credentials:
	1.  Open the `Constants.h` file.
	2.  Modify the `TOKEN_VENDING_MACHINE_URL` with the DNS domain name where your Token Vending Machine is running (ex: tvm.elasticbeanstalk.com).
	3.  Modify the `USE_SSL` to YES or NO based on whether your Token Vending Machine is running SSL or not.
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to `AWSiOSDemoTVM`
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the following frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSS3.framework
		*  AWSSimpleDB.framework
		*  AWSSQS.framework
		*  AWSSNS.framework
4.  Run the project.
