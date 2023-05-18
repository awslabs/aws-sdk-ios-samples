//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Combine
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {

    enum State {
        case unknown
        case signingOut
        case signedOut
        case signingUp
        case signedUpPendingConfirmation
        case signedUp
        case signingIn
        case signedIn
        case error(Error)
    }

    @Published private(set) var state: State = .unknown

    var auth: AuthCategory = Amplify.Auth
    var email: String = ""
    var password: String = ""
    
    func resolveState() {
        Task {
            do {
                _ = try await auth.getCurrentUser()
                self.state = .signedIn
            } catch {
                self.state = .signedOut
            }
        }
    }

    func signUp() {
        self.state = .signingUp
        Task {
            do {
                let result = try await _signUp()
                switch result.nextStep {
                case .confirmUser:
                    self.state = .signedUpPendingConfirmation
                case .done:
                    self.state = .signedUp
                }
            } catch {
                self.state = .error(error)
            }
        }
    }

    func _signUp() async throws -> AuthSignUpResult {
        return try await auth.signUp(username: email, password: password, options: .init(
            userAttributes: [
                .init(.email, value: email)
            ]
        ))
    }

    func signIn() {
        self.state = .signingIn
        Task {
            do {
                try await _signIn()
                self.state = .signedIn
            } catch {
                self.state = .error(error)
            }
        }
    }

    func _signIn() async throws {
        _ = try await auth.signIn(username: email, password: password)
    }

    func signOut() {
        self.state = .signingOut
        Task {
            _ = await auth.signOut()
            self.state = .signedOut
        }
    }

}
