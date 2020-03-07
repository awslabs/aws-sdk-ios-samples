/*
* Copyright 2010-2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

import Foundation
import AWSCore

//WARNING: To run this sample correctly, you must set the following constants.

let CertificateSigningRequestCommonName = "IoTSampleSwift Application"
let CertificateSigningRequestCountryName = "Your Country"
let CertificateSigningRequestOrganizationName = "Your Organization"
let CertificateSigningRequestOrganizationalUnitName = "Your Organizational Unit"

let POLICY_NAME = "YourPolicyName"

// This is the endpoint in your AWS IoT console. eg: https://xxxxxxxxxx.iot.<region>.amazonaws.com
let AWS_REGION = AWSRegionType.Unknown

//For both connecting over websockets and cert, IOT_ENDPOINT should look like
//https://xxxxxxx-ats.iot.REGION.amazonaws.com
let IOT_ENDPOINT = "https://xxxxxxxxxx.iot.<region>.amazonaws.com"
let IDENTITY_POOL_ID = "<REGION>:<UUID>"

//Used as keys to look up a reference of each manager
let AWS_IOT_DATA_MANAGER_KEY = "MyIotDataManager"
let AWS_IOT_MANAGER_KEY = "MyIotManager"
