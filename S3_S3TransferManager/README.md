#Running the S3_S3TransferManager Sample
This sample demonstrates the pause and resume features of the `S3TransferManager` found in the S3 SDK.

For a more detailed description of the code, please visit this [writeup](S3TransferManager.html).

1. Open the `S3TransferManager.xcodeproj` project file in Xcode.
1. Configure the sample with your AWS security credentials:
	1. Open the `Constants.h` file.
	1. Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.
1. Add the AWS SDK for iOS Frameworks to the sample. Get it [here](http://aws.amazon.com/sdkforios).
	1. In the **Project Navigator**, Right-Click on the **Frameworks** group.
	1. In the **Menu** select **Add Files** to `S3TransferManager`.
	1. Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	1. Select the following frameworks and click **Add**.
		* AWSRuntime.framework
		* AWSS3.framework
1. Run the project.
