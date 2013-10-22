/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#define TEST_TABLE_NAME              @"TestUserPreference"
#define TEST_TABLE_HASH_KEY          @"userNo"


//Fill in these two fields to bypass WIF
#define ACCESS_KEY_ID                @"CHANGE ME"
#define SECRET_KEY                   @"CHANGE ME"


/**
 * Enables FB Login.
 * Login with Facebook also requires the following things to be set
 *
 * FacebookAppID in App plist file
 * The appropriate URL handler in project (should match FacebookAppID)
 */
#define FB_LOGIN                    0

#if FB_LOGIN

#import <FacebookSDK/FacebookSDK.h>

/**
 * Role that user will assume after logging in.
 * This role should have appropriate policy to restrict actions to only required
 * services and resources.
 */
#define FB_ROLE_ARN @"FB_ARN"

#endif

/**
 * Enables Google+
 * Google+ login also requires the following things to be set
 *
 * The appropriate URL handler in project (Should be the same as BUNDLE_ID)
 */
#define GOOGLE_LOGIN                0

#if GOOGLE_LOGIN

#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

/**
 * Role that user will assume after logging in.
 * This role should have appropriate policy to restrict actions to only required
 * services and resources.
 */
#define GOOGLE_ROLE_ARN             @"GOOGLE_ARN"

/**
 * Client ID retrieved from Google API console
 */
#define GOOGLE_CLIENT_ID            @"GOOGLE_CLIENT_ID"

/**
 * Client scope that will be used with Google+
 */
#define GOOGLE_CLIENT_SCOPE         @"https://www.googleapis.com/auth/userinfo.profile"
#define GOOGLE_OPENID_SCOPE         @"openid"

#endif

/**
 * Enables Amazon
 * Login with Amazon also requires the following things to be set
 *
 * IBAAppAPIKey in App plist file
 * The appropriate URL handler in project (of style amzn-BUNDLE_ID)
 */
#define AMZN_LOGIN                  0

#if AMZN_LOGIN

#import "AIMobileLib.h"
#import "AIAuthenticationDelegate.h"
#import "AIError.h"

/**
 * Role that user will assume after logging in.
 * This role should have appropriate policy to restrict actions to only required
 * services and resources.
 */
#define AMZN_ROLE_ARN @"AMZN_ARN"

#endif

#define IDP_NOT_ENABLED_MESSAGE      @"This provider is not enabled, please refer to Constants.h to enabled this provider"
#define CREDENTIALS_ALERT_MESSAGE    @"Please update the Constants.h file with your Facebook or Google App settings."

@interface Constants:NSObject
{
}

+(NSString *)getRandomName;
+(NSArray *)getColors;
+(UIAlertView *)errorAlert:(NSString *)message;

@end
