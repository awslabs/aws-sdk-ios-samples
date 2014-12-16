## Running the HighScores Sample

This is a sample mobile application that demonstrates how to use SimpleDB to store a high score list using the AWS iOS SDK.

For a more detailed description of the code, please visit this [online article](http://aws.amazon.com/articles/8829919029640036).

1.  Open the `HighScores/HighScores.xcodeproj` project file in Xcode.
2.  Configure the sample with your AWS security credentials:
	1.  Open the `Constants.h` file.
	2.  Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.
		**DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.**
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to `HighScores`
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the follwing frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSSimpleDB.framework
4.  Run the project.
