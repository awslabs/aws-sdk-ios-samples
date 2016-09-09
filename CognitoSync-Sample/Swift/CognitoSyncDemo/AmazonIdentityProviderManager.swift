/*
 * Copyright 2016 BJSS, Inc. or its affiliates. All Rights Reserved.
 *
 * Created by Andrea Scuderi on 08/09/2016.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  https://github.com/bjss/aws-sdk-ios-samples/blob/master/LICENSE
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

import Foundation
import AWSCognitoIdentityProvider

class AmazonIdentityProviderManager: NSObject, AWSIdentityProviderManager {
  
  static let sharedInstance = AmazonIdentityProviderManager()
  private var loginCache = [NSString: NSString]()
  
  func logins() -> AWSTask {
    return AWSTask(result: loginCache)
  }
  
  func reset() {
    self.loginCache = [NSString: NSString]()
  }
  
  func mergeLogins(logins: [NSString : NSString]?) {
    var merge = [NSString : NSString]()
    merge = loginCache
    //Add new logins
    if let unwrappedLogins = logins {
      for (key, value) in unwrappedLogins {
        merge[key] = value
      }
      self.loginCache = merge
    }
  }
}
