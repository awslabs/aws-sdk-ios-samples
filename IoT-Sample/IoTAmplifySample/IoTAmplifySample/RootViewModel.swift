//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import Combine
import Foundation

final class RootViewModel: ObservableObject {

    enum State {
        case configuring
        case configured
        case error(Error)
    }

    @Published var state: State = .configuring

    func configure() {
        do {
            try _configure()
            self.state = .configured
        } catch {
            self.state = .error(error)
        }
    }

    func _configure() throws {
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.configure()
    }

}
