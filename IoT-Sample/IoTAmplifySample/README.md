# IoTAmplifySample

This sample application illustrates how to use amplify-swift (Amplify v2)
alongside the IoT target offered by aws-sdk-ios.

## Running

In order to run this app, you will need:

1. To have CocoaPods installed.
2. An Amplify application configured with the
   [Auth category](https://docs.amplify.aws/lib/auth/getting-started/q/platform/ios/).
   If you already have an Amplify application you may use it here by typing
   `amplify pull`.
3. An IoT certificate and corresponding policy. For this, you may follow the
   instructions in [IoT-Sample/Swift](../Swift/README.md).

Once you have those dependencies, you may to type:

```
pod install && \
open IoTAmplifySample.xcworkspace
```

From Xcode, make sure to update the **endpoint**, **region**, and **topic**
values in `DeviceCertificateClient.swift` to reflect your configuration.

### Existing Amplify Application

If you already have an existing amplify application, it should be as easy as
typing the following from the commandline set to this project as its working
directory:

```
amplify pull
```

This will generate the needed `amplifyconfiguration.json` and
`awsconfiguration.json` files this project needs in order to run.
