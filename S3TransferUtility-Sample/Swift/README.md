# The Amazon S3 Background Transfer Sample

This sample demonstrates how to use `AWSS3TransferUtility` to download / upload files in background.

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

1. Add the required S3 resource to your app's cloud-enabled backend using the following CLI command:

		amplify add storage

1. Choose `Content` as your storage service.

		❯ Content (Images, audio, video, etc.)

1. The CLI walks you through the options to enable Auth (if not enabled previously), to name your S3 bucket, and to decide who should have access (select Auth and guest users and read/write for both auth and guest users).

1. Confirm that you have storage and auth set up with the following command:

		amplify status

1. Create the specified backend by running the following command:

		amplify push

1. Open `S3TransferUtilitySampleSwift.xcworkspace`.

1. Add the cli-generated `awsconfiguration.json` by right-clicking the project in Xcode project navigator, selecting `Add Files to "S3TransferUtilitySampleSwift"..."` and following instructions in the dialog window.

1. Build and run the sample app.

## NOTES

1. The TransferUtility uses a `NSURL Background Session` to upload and download files. To make sure that the transfers continue to run when the app is moved to the background, the `handleEventsForBackgroundURLSession` method has to be implemented in the `AppDelegate`.  The sample implements this as follows

	Swift

       func application(_ application: UIApplication, 
                       handleEventsForBackgroundURLSession identifier: String, 
                       completionHandler: @escaping () -> Void) {
        
            //provide the completionHandler to the TransferUtility to support background transfers.
            AWSS3TransferUtility.interceptApplication(application, 
                handleEventsForBackgroundURLSession: identifier, 
                completionHandler: completionHandler)
        }

	Objective-C

       (void) application:(UIApplication *)application 
              handleEventsForBackgroundURLSession:(NSString *)identifier 
              completionHandler:(void (^)(void))completionHandler {

           //provide the completionHandler to the TransferUtility to support background transfers.
           [AWSS3TransferUtility interceptApplication:application
               handleEventsForBackgroundURLSession:identifier
                             completionHandler:completionHandler];
       }	

1. If, you get a bunch of warnings that look similar to the one below when you run the sample and try doing an upload:

		Function boringssl_session_errorlog: line 2868 [boringssl_session_write] SSL_ERROR_SYSCALL(5): operation failed externally to the library
		2017-12-22 10:46:37.105342-0800 S3TransferManagerSampleSwift[59012:3381604] [BoringSSL]

	You can disable OS logging in Xcode to make them go away.  With your project window open, go to Project -> Scheme -> Edit Scheme... and add "OS_ACTIVITY_MODE" to the Environment Variables section and set its value to "disable".  When you rerun the app those warnings should now not appear.
