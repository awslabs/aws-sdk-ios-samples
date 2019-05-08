//
// Copyright 2010-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

import Foundation
import AWSCore

// WARNING: To run this sample correctly, you must set the following constants.

let LexRegion = AWSRegionType.Unknown                       // Change this is this is not your Lex region (most are currently AWSRegionType.USEast1)
let BotName = "BotName"                                     // Put your bot name here
let BotAlias = "$LATEST"                                    // You can leave this if you always want to use
                                                            // the latest version of your bot or put the version
