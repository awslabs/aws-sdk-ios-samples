/**
 * Copyright 2012-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy
 * of the License is located at
 *
 * http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "AIError.h"
#import "AIAuthenticationDelegate.h"

/**
  Key name for defining whether to force a refresh of the access token.

  Pass this key with a string value of "YES" to `getAccessTokenForScopes:withOverrideParams:delegate:` to force the
  method to refresh the access token.
*/
extern const NSString *kForceRefresh;

/**
  AIMobileLib is a static class that contains Login with Amazon APIs.

  This class provides APIs for getting authorization from users, getting profile information, clearing authorization
  state, and getting authorization tokens to access secure data.
*/
@interface AIMobileLib : NSObject

/**
  Allows the user to login and, if necessary, authorize the app for the requested scopes.

  Use this method to request authorization from the user for the required scopes. If the user has not logged in, they
  will see a login page.  Afterward, if they have not previously approved these scopes for your app, they will see a
  consent page.

  The sign-in page is displayed in Safari, so there will be a visible switch from the app to Safari. After the user
  signs in on the browser, they are redirected back to the app. The app must define
  `[UIApplicationDelegate application:openURL:sourceApplication:annotation]` in the app delegate and call the
  `handleOpenURL:sourceApplication:` API from that delegate method. This allows the SDK to get the login information
  from the Safari web browser.

  Scopes that can be used with this API are:

  - "profile": This scope enables an app to request profile information from the backend server. The profile
    information includes customer's name, email and user_id.
  - "postal_code": This scope enables an app to request the postal code registered to the user's account.

  The result of this API is sent to the `delegate`. On success, `[AIAuthenticationDelegate requestDidSucceed:]` is
  called. The app can now call `getProfile:` to retrieve the user's profile data, or
  `getAccessTokenForScopes:withOverrideParams:delegate:` to retrieve the raw access token. On failure,
  `[AIAuthenticationDelegate requestDidFail:]` is called. The error code and an error message are passed to the method
  in the APIError object. Error codes that can be returned by this API are:

  - `kAIServerError` : The server encountered an error while completing the request, or the SDK received an unknown
                       response from the server.  You can allow the user to login again.
  - `kAIErrorUserInterrupted` : The user canceled the login page.  You can allow the user to login again.
  - `kAIAccessDenied` : The user did not consent to the requested scopes.
  - `kAIDeviceError` : The SDK encountered an error on the device. The SDK returns this when there is a problem with the
                       Keychain. Calling `clearAuthorizationState:` will help.
  - `kAIInvalidInput` : One of the API parameters is invalid.  See the error message for more information.
  - `kAINetworkError` : A network error occurred, possibly due to the user being offline.
  - `kAIUnauthorizedClient` : The app is not authorized to make this call.
  - `kAIInternalError` : An internal error occurred in the SDK.  You can allow the user to login again.

  @param scopes The profile scopes that the app is requesting from the user. The first scope must be "profile".
                "postal_code" is an optional second scope.
  @param authenticationDelegate A delegate implementing the `AIAuthenticationDelegate` protocol to receive success and
                                failure messages.
  @since 1.0
*/
+ (void)authorizeUserForScopes:(NSArray *)scopes delegate:(id <AIAuthenticationDelegate>)authenticationDelegate;

/**
  Once the user has logged in, this method will return a valid access token for the requested scopes.

  This method returns a valid access token, if necessary by exchanging the current refresh token for a new access token.
  If the method is successful, this access token is valid for the requested scopes.

  Scopes that can be used with this API are:

  - "profile": This scope enables an app to request profile information from the backend server. The profile
    information includes customer's name, email and user_id.
  - "postal_code": This scope enables an app to request the postal code registered to the user's account.

  Values that can be used in `overrideParams`:

  - `kForceRefresh` - Forces the SDK to refresh the access token, discarding the current one and retrieving a new one.

  The result of this API is sent to the `delegate`. On success, `[AIAuthenticationDelegate requestDidSucceed:]` is
  called. The new access token is passed in the result property of the APIResult parameter.  The app can then use the
  access token directly with services that support it. On failure, `[AIAuthenticationDelegate requestDidFail:]` is
  called. The error code and an error message are passed to the method in the APIError object. Error codes that can be
  returned by this API are:

  - `kAIApplicationNotAuthorized` : The app is not authorized for scopes requested. Call
                                    `authorizeUserForScopes:delegate:` to allow the user to authorize the app.
  - `kAIServerError` : The server encountered an error while completing the request, or the SDK received an unknown
                       response from the server.  You can allow the user to login again.
  - `kAIDeviceError` : The SDK encountered an error on the device. The SDK returns this when there is a problem with the
                       Keychain. Calling `clearAuthorizationState:` will help.
  - `kAIInvalidInput` : One of the API parameters is invalid.  See the error message for more information.
  - `kAINetworkError` : A network error occurred, possibly due to the user being offline.
  - `kAIUnauthorizedClient` : The app is not authorized to make this call.
  - `kAIInternalError` : An internal error occurred in the SDK.  You can allow the user to login again.

 @param scopes The profile scopes that the app is requesting from the user. The first scope must be "profile".
                "postal_code" is an optional second scope.
 @param authenticationDelegate A delegate implementing the `AIAuthenticationDelegate` protocol to receive success and
                               failure messages.
 @param overrideParams Dictionary of optional keys to alter behavior of this function.
 @since 1.0
*/
+ (void)getAccessTokenForScopes:(NSArray *)scopes
             withOverrideParams:(NSDictionary *)overrideParams
                       delegate:(id <AIAuthenticationDelegate>)authenticationDelegate;

/**
  Deletes cached user tokens and other data.  Use this method to logout a user.

  This method removes the authorization tokens from the Keychain. It also clears the cookies from the local cookie
  storage to clear the authorization state of the users who checked the "Remember me" checkbox.

  The result of this API is sent to the `delegate`. On success, `[AIAuthenticationDelegate requestDidSucceed:]` is
  called. On failure, `[AIAuthenticationDelegate requestDidFail:]` is called. The error code and an error message are
  passed to the method in the APIError object. Error codes that can be returned by this API are:

  - `kAIDeviceError` : The SDK encountered an error on the device. The SDK returns this when there is a problem with the
                       Keychain.
  - `kAIInvalidInput` : One of the API parameters is invalid.  See the error message for more information.

 @param authenticationDelegate A delegate implementing the `AIAuthenticationDelegate` protocol to receive success and
                               failure messages.
 @since 1.0
*/
+ (void)clearAuthorizationState:(id <AIAuthenticationDelegate>)authenticationDelegate;

/**
  Use this method to get the profile of the current authorized user.

  This method gets profile information for the current authorized user. The app should make sure it is authorized for
  the "profile" scope prior to calling this method.  If the app is authorized for the "postal_code" scope,
  getProfile will return that information as well.  This profile information is cached for 60 minutes.

  The result of this API is sent to the `delegate`. On success, `[AIAuthenticationDelegate requestDidSucceed:]` is
  called. The user profile is passed in the result property of the APIResult parameter as an NSDictionary. The following
  keys are used:

  - "name" : The name of the user.
  - "email" : The registered email address of the user.
  - "user_id" : The used id of the user, in the form of "amzn1.user.VALUE".  The user id is unique to the user.
  - "postal_code" : The registered postal code of the user.

  On failure, `[AIAuthenticationDelegate requestDidFail:]` is called. The error code and an error message are passed to
  the method in the APIError object. Error codes that can be returned by this API are:

  - `kAIApplicationNotAuthorized` : The app is not authorized for scopes requested. Call
                                    `authorizeUserForScopes:delegate:` to allow the user to authorize the app.
  - `kAIServerError` : The server encountered an error while completing the request, or the SDK received an unknown
                       response from the server.  You can allow the user to login again.
  - `kAIDeviceError` : The SDK encountered an error on the device. The SDK returns this when there is a problem with the
                       Keychain. Calling `clearAuthorizationState:` will help.
  - `kAIInvalidInput` : One of the API parameters is invalid.  See the error message for more information.
  - `kAINetworkError` : A network error occurred, possibly due to the user being offline.
  - `kAIInternalError` : An internal error occurred in the SDK.  You can allow the user to login again.

 @param authenticationDelegate A delegate implementing the `AIAuthenticationDelegate` protocol to receive success and
                               failure messages.
 @since 1.0
*/
+ (void)getProfile:(id <AIAuthenticationDelegate>)authenticationDelegate;

/**
  Helper function for `authorizeUserForScopes:delegate:`.

  Call this function from your implementation of the
  `[UIApplicationDelegate application:openURL:sourceApplication:annotation]` delegate. This method handles the
  `[UIApplicationDelegate application:openURL:sourceApplication:annotation]` call from the Safari web browser. The app
  should be calling this function when it receives a call to
  `[UIApplicationDelegate application:openURL:sourceApplication:annotation]`, passing in the `url` and the
  `sourceApplication`. If app fails to do so, the SDK will not be able to complete the login flow.

  The SDK validates the `url` parameter to see if it is valid for the SDK. It is possible the app may want to handle the
  `url` as well, in which case the app should first call the SDK to see if this `url` is a callback from Safari and if
  the SDK wants to process it. After processing, the SDK will return its preference and the app can then process the
  `url` if it chooses. Any error arising from this API is reported through the failure delegate used for the
  `authorizeUserForScopes:delegate:` call.

 @param url The url received in the `[UIApplicationDelegate application:openURL:sourceApplication:annotation]` delegate
            method.
 @param sourceApplication The sourceApplication received in the
                          `[UIApplicationDelegate application:openURL:sourceApplication:annotation]` delegate method.
 @return Returns YES if the url passed in was a valid url for the SDK and NO if the url was not valid.
 @see See `authorizeUserForScopes:delegate:` for more discussion on how to work with this API to complement the login
      work flow.
 @since 1.0
*/
+ (BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

@end
