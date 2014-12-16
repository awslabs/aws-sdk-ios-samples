##Running the S3_S3TransferManager Sample
This sample demonstrates the pause and resume features of the S3TransferManager found in the S3 SDK.
For a more detailed description of the code, please visit this [writeup](S3TransferManager.html).

1. Open the <code>S3TransferManager.xcodeproj</code> project file in Xcode.
2. Configure the sample with your AWS security credentials:
	1. Open the <code>Constants.h</code> file.
    2. Modify the <code>ACCESS_KEY</code> and <code>SECRET_KEY</code> definitions with your AWS Credentials.  
	**DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.**
3. Add the AWS SDK for iOS Frameworks to the sample. Get it [here](http://aws.amazon.com/sdkforios/).
  	1. In the Project Navigator, Right-Click on the Frameworks group.
  	2. In the Menu select Add Files to "S3TransferManager"
  	3. Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
  	4. Select the follwing frameworks and click Add
  		* AWSRuntime.framework
  		* AWSS3.framework
4. Run the project.