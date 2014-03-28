## Running the FeedbackForm Sample

This is a sample mobile application that demonstrates how to use Amazon SES to record user feedback using the AWS iOS SDK.

For a more detailed description of the code, please visit this [online article](http://aws.amazon.com/articles/3290993028247679).

1.  Open the `FeedbackForm/FeedbackForm.xcodeproj` project file in Xcode.
2.  Configure the sample with your AWS security credentials:
	1.  Open the `Constants.h` file.
	2.  Modify the `ACCESS_KEY` and `SECRET_KEY` definitions with your AWS Credentials.  
		**DO NOT EMBED YOUR CREDENTIALS IN PRODUCTION APPS.**
	3.  (Verify your email address if you haven't done it before:)
		*  Go to AWS SES Console
		*  Click "Email Addresses" Under "Verified Senders" section on left of the screen.
		*  Click "Verify a New Email Address" and then enter your email address.
		*  Go to your email inbox and click the link to verify this address.
	4. Modify the `VERIFIED_EMAIL` definitions with your verified email address.
3.  Add the AWS SDK for iOS Frameworks to the sample.
	1.  In the Project Navigator, Right-Click on the Frameworks group.
	2.  In the Menu select Add Files to "FeedbackForm"
	3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
	4.  Select the follwing frameworks and click Add:
		*  AWSRuntime.framework
		*  AWSSES.framework
4.  Run the project.
