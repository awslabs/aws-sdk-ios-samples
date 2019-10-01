//
// Copyright 2018-2019 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Data {
    func toHexString() -> String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
