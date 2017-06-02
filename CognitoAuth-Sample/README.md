# Introduction

The Amazon Cognito Auth SDK for iOS simplifies adding sign-up, sign-in functionality in your apps. With this SDK, you can use Cognito User Pools’ app integration and federation features, with a customizable UI hosted by AWS to sign up and sign in users, and with built-in federation for external identity providers via SAML. These features are currently (as of 6/1/2017) in public beta. To learn more see our [Developer Guide](http://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-federation-beta-release-overview.html).

If you are looking for our SDK to access all user APIs for Cognito User Pools, see the [iOS Cognito Identity Provider SDK](https://github.com/aws/aws-sdk-ios/tree/master/AWSCognitoIdentityProvider).

# Installing the SDK
Follow the instructions here: [Set Up the Mobile SDK for iOS.](http://docs.aws.amazon.com/mobile/sdkforios/developerguide/setup-aws-sdk-for-ios.html)

# Imports
If you are using CocoaPods, add pod `AWSCognitoAuth` to your PodSpec and `#import AWSCognitoCognitoAuth.h` in the classes you want to use it.

If you are using Frameworks, add `AWSCognitoAuth.framework` and `#import <AWSCognitoAuth/AWSCognitoAuth.h>` in the classes you want to use it.

For Swift use: `import AWSCognitoAuth`

# Configuration
You have 2 options for configuring your `AWSCognitoAuth` object.

## Via Info.plist
This method places the configuration in your Info.plist

Right click on `Info.plist` and click `Open As->Source Code`

Add the following keys:

```xml
<key>AWS</key>
    <dict>
        <key>CognitoUserPool</key>
        <dict>
            <key>Default</key>
            <dict>
                <key>CognitoUserPoolAppClientId</key>
                <string>SETME</string>
                <key>CognitoUserPoolAppClientSecret</key>
                <string>SETME</string>
                <key>CognitoAuthWebDomain</key>
                <string>SETME</string>
                <key>CognitoAuthSignInRedirectUri</key>
                <string>SETME</string>
                <key>CognitoAuthSignOutRedirectUri</key>
                <string>SETME</string>
                <key>CognitoAuthScopes</key>
                <array>
                    <string>SETME</string>
                </array>
            </dict>
        </dict>
    </dict>
```

Replace all of the _SETME_ with the appropriate value as described below.

1. **CognitoUserPoolAppClientId** Your app client id, i.e 81q37d9nfu607gil4uhopekm4b
2. **CognitoUserPoolAppClientSecret** _Optional_ Your app client secret, i.e. 45dpc0bk45v8alftrjv4afeu4nduz1b7do5mjqtia36r7cbnl4d9. If you don't have a client secret, completely remove this key/string pair.
3. **CognitoAuthWebDomain** Your domain, i.e. https://yourdomain.auth.region.amazoncognito.com
4. **CognitoAuthSignInRedirectUri** Your sign in redirect uri, i.e myapp://signin
5. **CognitoAuthSignOutRedirectUri** Your sign out redirect uri, i.e. myapp://signout
6. **CognitoAuthScopes** Array containing scopes to request, i.e. aws.cognito.signin.user.admin

While you are editing the `info.plist` you should also take the time to Configure Custom Uri Schemes as described below.

## Via AWSCognitoAuthConfiguration
__Objective-C__

```
AWSCognitoAuthConfiguration * configuration = [[AWSCognitoAuthConfiguration alloc] initWithAppClientId:@"SETME"
                                                                                           appClientSecret: @"SETME"
                                                                                                    scopes:[NSSet setWithArray:@[@"SETME"]]
                                                                                         signInRedirectUri:@"SETME"
                                                                                        signOutRedirectUri:@"SETME"
                                                                                                 webDomain:@"SETME"];
```
__Swift__
```
let configuration = AWSCognitoAuthConfiguration(appClientId: "SETME", appClientSecret: "SETME", scopes: Set(["SETME"]), signInRedirectUri: "SETME", signOutRedirectUri: "SETME", webDomain: "SETME")
```

Replace all of the _SETME_ with the appropriate value as described in above.

Register an AWSCognitoAuth object with the configuration you just created.

__Objective-C__
```
[AWSCognitoAuth registerCognitoAuthWithAuthConfiguration:configuration forKey:@"cognitoAuth"];
```

__Swift__
```
AWSCognitoAuth.registerCognitoAuth(with: configuration, forKey: "cognitoAuth")
```

# Configure Custom Uri Schemes

Right click on `Info.plist` and click `Open As->Source Code`

Add the following keys:

```
<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>SETME</string>
			</array>
			<key>CFBundleURLName</key>
			<string>${PRODUCT_BUNDLE_IDENTIFIER}</string>
		</dict>
	</array>
```

Replace all of the _SETME_ with the appropriate value as described above.

**CFBundleURLSchemes** Your redirect scheme configured for your app client, i.e myapp

#Access your AWSCognitoAuthObject
To access your AWSCognitoAuth object, if you used the `Info.plist` method:

__Objective-C__

```
AWSCognitoAuth *cognitoAuth = [AWSCognitoAuth defaultCognitoAuth];
```

__Swift__

```
let cognitoAuth = AWSCognitoAuth.default()
```

If you used the `AWSCognitoAuthConfiguration` method:

__Objective-C__

```
AWSCognitoAuth *cognitoAuth = [AWSCognitoAuth CognitoAuthForKey:@"cognitoAuth"]
```

__Swift__

```
let cognitoAuth = AWSCognitoAuth(forKey: "cognitoAuth")
```
# Override openURL 

AWSCognitoAuth needs to extract details from the request to obtain a valid session when it redirects into your app.

Override the `openURL` method in your `AppDelegate.m`.  Tweak how you access the `AWSCognitoAuth` object based on how you set it up above.


__Objective-C__

```
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    return [[AWSCognitoAuth defaultCognitoAuth] application:app openURL:url options:options];
}
```

__Swift__

```
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return AWSCognitoAuth.default().application(app, open: url, options: options)
}
```

# Get a Session

From a view controller

__Objective-C__

```
AWSCognitoAuth * cognitoAuth = [AWSCognitoAuth defaultCognitoAuth];
[cognitoAuth getSession:self completion:^(AWSCognitoAuthUserSession * _Nullable session, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@", error.userInfo[@"error"]);
        }else {
            //Do something with session
            NSLog(@"Claims: %@", t.result.idToken.claims);        
        }
    }];

```

__Swift__

```
let cognitoAuth = AWSCognitoAuth.default()
cognitoAuth.getSession(self)  { (session:AWSCognitoAuthUserSession?, error:Error?) in
            if(error != nil) {
                print((error! as NSError).userInfo["error"] as? String)
            }else {
                //Do something with session
            }
        }
```
    
# Sign out

From a view controller

__Objective-C__

```
[cognitoAuth signOut:self completion:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@", error.userInfo[@"error"]);
        }else {
            //User successfully signed out
            NSLog(@"User signed out");        
        }
    }];
```

__Swift__

```
cognitoAuth.signOut { (error:Error?) in
            if(error != nil) {
                print((error! as NSError).userInfo["error"] as? String)
            }else {
                //User signed out successfully
            }
        }
```

# Optionally implement AWSCognitoAuthDelegate
If your flow is such that you are not explicitly invoking getSession from a view controller, you may need to provide the current view controller to display over.

Implement the protocol `AWSCognitoAuthDelegate` and set it as the delegate.

__Objective-C__

```
- (UIViewController *) getViewController {
    return self;
}

cognitoAuth.delegate = self;
```

__Swift__

```
func getViewController() -> UIViewController {
       return self
}

cognitoAuth.delegate = self
```

# Get AWS Credentials

Obtaining AWS credentials is not implemented in this beta out of box.  You will need to include `AWSCore`, implement the `AWSIdentityProviderManager` protocol and provide the id token from `getSession` in the `logins` method.
