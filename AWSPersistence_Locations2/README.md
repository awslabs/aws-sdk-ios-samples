## Running the AWSPersistence_Locations2

This is a sample mobile application that demonstrates how to use the AWS Persistence Framework For Core Data. For more details about Persistence Framework,please visit this [online article](http://aws.amazon.com/articles/4435846131581972).

This sample use the [Token Vending Machine](http://aws.amazon.com/articles/4611615499399490) without requiring an identity from the user.

It is assumed that you are currently running the [Anonymous](http://aws.amazon.com/code/8872061742402990) version of the TVM, token vending machine.

1.  Open the `AWSPersistence_Locations2/Locations2.xcodeproj` project file in Xcode.
2.  Configure the sample with your Token Vending Machine credentials:
    1.  Open the `Constants.h` file.
    2.  Modify the `TOKEN_VENDING_MACHINE_URL` with the DNS domain name where your Token Vending Machine is running (ex: tvm.elasticbeanstalk.com).
    3.  Modify the `USE_SSL` to YES or NO based on whether your Token Vending Machine is running SSL or not.
3.  Add the AWS SDK for iOS Frameworks to the sample.
    1.  In the Project Navigator, Right-Click on the Frameworks group.
    2.  In the Menu select Add Files to `AWSPersistence_Locations2`
    3.  Navigate to the location where you downloaded and expanded the AWS SDK for iOS.
    4.  Select the following frameworks and click Add:
         *  AWSRuntime.framework
         *  AWSDynamoDB.framework
         *  AWSPersistence.framework

4.  Run the project.
