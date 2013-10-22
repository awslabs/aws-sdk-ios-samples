aws-sdk-ios-samples
===================

This repository has samples that demonstrate various aspects of the AWS SDK for iOS, get the [source on Github](https://github.com/aws/aws-sdk-ios).

Please refer to README file in each folder for more specific instructions.

### List of Samples
    
#### [DynamoDB_WIF_UserPreference](DynamoDB_WIF_UserPreference/README.md)
* This is a sample mobile application that demonstrates how to use Amazon DynamoDB to store a user preferences by using Web Identity Federation.
    * AWS Services involved:
      + DynamoDB
      + Security Token Service

#### [S3_SimpleDB_SNS_SQS_Demo](S3_SimpleDB_SNS_SQS_Demo/README.md)
* This is a sample mobile application that demonstrates how to make requests to AWS using the iOS SDK.
    * AWS Services involved:
      + Simple Storage (S3)
      + SimpleDB
      + Simple Queue Service (SQS)
      + Simple Notification Service (SNS)

#### [S3_SimpleDB_SNS_SQS_DemoTVM](S3_SimpleDB_SNS_SQS_DemoTVM/README.md)
* This is a sample mobile application demonstrates interaction with the Token Vending Machine without requiring an identity from the user.
    * AWS Services involved:
      + Simple Storage (S3)
      + SimpleDB
      + Simple Queue Service (SQS)
      + Simple Notification Service (SNS)
      + Token Vending Machine (Anonymous version)

#### [S3_SimpleDB_SNS_SQS_DemoTVMIdentity](S3_SimpleDB_SNS_SQS_DemoTVMIdentity/README.md)
* This is a sample mobile application demonstrates interaction with a Token Vending Machine where a username/password combination is required.
    * AWS Services involved:
      + Simple Storage (S3)
      + SimpleDB
      + Simple Queue Service (SQS)
      + Simple Notification Service (SNS)
      + Token Vending Machine (Identity version)

#### [S3_Uploader](S3_Uploader/README.md)
* This is a sample mobile application that demonstrates how to make requests to Amazon S3 using the iOS SDK.
    * AWS Services involved:
      + Simple Storage (S3)

#### [S3_WIF_PersonalFileStore](S3_WIF_PersonalFileStore/README.md)
* The is a sample mobile application that demonstrates how to use AWS Security Token Service (STS) to give application users specific and constrained permissions to an Amazon S3 bucket. 
    * AWS Services involved:
      + Simple Storage (S3)
      + Security Token Service

#### [SES_FeedbackForm](SES_FeedbackForm/README.md)
* This is a sample mobile application demonstrates how to use Amazon SES to record user feedback using the AWS iOS SDK.
    * AWS Services involved:
      + Simple Storage (S3)
      + Simple Email Service (SES)

#### [AWSPersistence_Locations2](AWSPersistence_Locations2/README.md)
* This is a sample mobile application that demonstrates how to use AWSPersistence framework.
    * AWS Services involved:
      + DynamoDB
      + AWS Persistence Framework for Core Data

#### [SimpleDB_HighScores](SimpleDB_HighScores/README.md)
* This is a sample mobile application that demonstrates how to use SimpleDB to store a high score list using the AWS iOS SDK.
    * AWS Services involved:
      + SimpleDB

#### [SNS_SQS_MessageBoard](SNS_SQS_MessageBoard/README.md)
* This is a sample mobile application that demonstrates how to use Amazon SQS and Amazon SNS to create a message board using the AWS iOS SDK.
    * AWS Services involved:
      + Simple Notification Service (SNS)
      + Simple Queue Service (SQS)
