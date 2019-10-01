# AWS Pinpoint Sample App

**Disclaimer:** This app is not an officially supported Sample application. Its usage is limited to testing and reproducing Pinpoint-related issues by the development team. Therefore, the code here does not represent implementation suggestions and/or best practices.

## Requirements

* Xcode 10.1 and later
* iOS 9 and later

## Using the Sample

1. The AWS Mobile SDK for iOS is available through [CocoaPods](http://cocoapods.org). If you have not installed CocoaPods, install CocoaPods:

```sh
sudo gem install cocoapods
pod setup
```

1. To install the AWS Mobile SDK for iOS, change the current directory to the one with your **Podfile** in it and run the following command:

```sh
pod install
```

1. Create new AWS backend resources and pull the AWS services configuration into the app by running the following command:

```
amplify init  # accept default options to get started
```

1. Add the required S3 resource to your app's cloud-enabled backend using the following CLI command:

```
amplify add analytics
```

1. The CLI walks you through the options to enable Analytics. Confirm that you have analytics set up with the following command:

```
amplify status
```

1. Create the specified backend by running the following command:

```
amplify push
```

1. Open `PinpointSample.xcworkspace`.

1. Add the cli-generated `awsconfiguration.json` by right-clicking the project in Xcode project navigator, selecting `Add Files to "PinpointSample"..."` and following instructions in the dialog window.

1. Build and run the sample app.
