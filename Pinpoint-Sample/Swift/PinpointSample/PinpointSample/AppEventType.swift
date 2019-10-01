//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

enum AppEventType: String {
    case appDidBecomeActive = "app.did_become_active"
    case appDidEnterBackground = "app.did_enter_background"
    case appWillEnterForeground = "app.will_enter_foreground"
    case appWillResignActive = "app.will_resign_active"
    case appWillTerminate = "app.will_terminate"
}
