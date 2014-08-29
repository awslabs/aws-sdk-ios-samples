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

@class AIError;

#pragma mark - API

/**
  These constants identify which API succeeded or failed when calling AIAuthenticationDelegate. The value identifying
  the API is passed in the APIResult and APIError objects.

  @since 1.0
*/
typedef NS_ENUM(NSUInteger, API) {
    /** Refers to `[AIMobileLib authorizeUserForScopes:delegate:]` */
    kAPIAuthorizeUser = 1,
    /** Refers to `[AIMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]` */
    kAPIGetAccessToken = 2,
    /** Refers to `[AIMobileLib clearAuthorizationState:]` */
    kAPIClearAuthorizationState = 3,
    /** Refers to `[AIMobileLib getProfile:]` */
    kAPIGetProfile = 4
};

#pragma mark - APIResult
/**
  This class encapsulates success information from an AIMobileLib API call.
*/
@interface APIResult : NSObject

- (id)initResultForAPI:(API)anAPI andResult:(id)theResult;

/**
  The result object returned from the API on success. The API result can be `nil`, an `NSDictionary`, or an `NSString`
  depending upon which API created the APIResult.

- `[AIMobileLib authorizeUserForScopes:delegate:]` : Passes `nil` as the result to the delegate.
- `[AIMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]` : Passes an access token as an `NSString` object
  to the delegate.
- `[AIMobileLib clearAuthorizationState:]` : Passes nil as the result to the delegate.
- `[AIMobileLib getProfile:]` : Passes profile data in an `NSDictionary` object to the delegate. See the API description
  for information on the key:value pairs expected in profile dictionary.

  @since 1.0
 */
@property (retain) id result;

/**
  The API returning the result.

  @since 1.0
*/
@property API api;

@end

#pragma mark - APIError

/**
  This class encapsulates the failure result from an AIMobileLib API call.
*/
@interface APIError : NSObject

- (id)initErrorForAPI:(API)anAPI andError:(id)theErrorObject;

/**
  The error object returned from the API on failure.

  @see See AIError for more details.

  @since 1.0
*/
@property (retain) AIError *error;

/**
  The API which is returning the error.

  @since 1.0
*/
@property API api;

@end

#pragma mark - AIAuthenticationDelegate
/**
  Applications calling AIMobileLib APIs must implement the methods of this protocol to receive success and failure
  information.
*/
@protocol AIAuthenticationDelegate <NSObject>

@required

/**
  The APIs call this delegate method with the result when it completes successfully.

  @param apiResult An APIResult object containing the information about the calling API and the result generated.
  @see See APIResult for more information on the content of the apiResult.
  @since 1.0
*/
- (void)requestDidSucceed:(APIResult *)apiResult;


/**
 The APIs call this delegate method with the result when it fails.

 @param errorResponse An APIResult object containing the information about the API and the error that occurred.
 @see See APIError for more information on the content of the result.
 @since 1.0
*/
- (void)requestDidFail:(APIError *)errorResponse;

@end
