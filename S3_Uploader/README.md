##Running the S3Uploader Sample

This is a sample mobile application that demonstrates how to make requests to Amazon S3 using the iOS SDK.

For a more detailed description of the code, please visit this [online article](http://aws.amazon.com/articles/3002109349624271).

1.  Open the `S3Uploader/S3Uploader.xcodeproj` project file in Xcode.
2.  Configure the sample with your AWS security credentials:
	1.  Open the Constants.h file.
	2.  Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to "S3Uploader"
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
  	4.  Select the follwing frameworks and click Add
	    * AWSRuntime.framework
	    * AWSS3.framework
4.  Run the project.
