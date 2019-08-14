# The Amazon Photo Album Sample

This sample app demonstrates how to use the Authentication, Storage and AppSync iOS Mobile SDKs. This tutorial will show how to run the Photo Album sample app locally. The Photo Album sample app allows users to sign up, sign in and sign out using Auth with AWSMobileClient; add, delete, update and query albums using AppSync GraphQL; upload and download through S3 buckets using S3 TransferUtility.

## Requirements

* Xcode 9.2 and later
* iOS 8 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

		sudo gem install cocoapods
		pod setup

1. To install the AWS Mobile SDK for iOS, change the current directory to the one with your **Podfile** in it and run the following command:

		pod install

1. Create new AWS backend resources and pull the AWS services configuration into the app by running the following command:

		amplify init  # accept default options to get started
		amplify push  # create the configuration file

1. Add the required auth resource to your app's cloud-enabled backend using the following CLI command:

		amplify add auth

1. Set the prompts as follows:
    ```
    Do you want to use the default authentication and security configuration? (Use arrow keys)
    ❯ Default configuration 
      Default configuration with Social Provider (Federation) 
      Manual configuration 
      I want to learn more. 
    
    How do you want users to be able to sign in when using your Cognito User Pool? (Use arrow keys)
    ❯ Username 
      Email 
      Phone Number 
      Email and Phone Number 
      I want to learn more. 
    
    What attributes are required for signing up? (Press <space> to select, <a> to toggle all, <i> to invert selection)
      ◯ Address (This attribute is not supported by Facebook, Google, Login With Amazon.)
      ◯ Birthdate (This attribute is not supported by Login With Amazon.)
      ❯◉ Email
      ◯ Family Name (This attribute is not supported by Login With Amazon.)
      ◯ Middle Name (This attribute is not supported by Google, Login With Amazon.)
      ◯ Gender (This attribute is not supported by Login With Amazon.)
    
    ```
1. Add the required S3 resource to your app's cloud-enabled backend using the following CLI command:

		amplify add storage

1. Choose `Content` as your storage service.

		❯ Content (Images, audio, video, etc.)

1. The CLI walks you through the options to enable Auth (if not enabled previously), to name your S3 bucket, and to decide who should have access (select Auth and guest users and read/write for both auth and guest users).

1. Add the required api resource to your app's cloud-enabled backend using the following CLI command:

		amplify add api

1. Set the prompts as follows:
    ```
    ? Please select from one of the below mentioned services (Use arrow keys)
    ❯ GraphQL
      REST
    ? Provide API name: PhotoAlbum
    ? Choose an authorization type for the API (Use arrow keys)
    ❯ API key
      Amazon Cognito User Pool
    ? Do you have an annotated GraphQL schema? Yes
    ? Provide your schema file path: simple_model.graphql
    
    ```
1. This will create a file named API.swift in your root directory (unless you choose to name it differently) as well as a directory called graphql with your documents after running amplify push.

1. Confirm that you have auth, storage and api set up with the following command:

		amplify status

1. Create the specified backend by running the following command:

		amplify push

1. Open `PhotoAlbum.xcworkspace`.

1. Add the cli-generated `awsconfiguration.json` by right-clicking the project in Xcode project navigator, selecting `Add Files to "PhotoAlbum"..."` and following instructions in the dialog window.

1. Build and run the sample app.

## NOTES

1. The app initializes ```AWSMobileClient.sharedInstance(), AWSAppSyncClient() and AWSS3TransferUtility.default() ``` in the ```AWSServiceManager.swift``` file to access Authentication, API and Storage respectively. Please refer to this file for more information.

1. In order to run the UI Tests for the demo app, please sign up a test user and add the test user credentials in the ```UIActions.swift``` file here: 
    ```
    static var username = "testuser2"
    static var password = "abc@123!"
    
    ```

1. Please refer to [AWS iOS Mobile SDK Getting Started Guide](https://aws-amplify.github.io/docs/ios/start) for more information on the usage of AWS iOS Mobile SDK.
