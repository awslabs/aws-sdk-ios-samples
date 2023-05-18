//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import AWSCognitoAuthPlugin
import AWSCore
import AWSPluginsCore
import Amplify
import Foundation

/// Convenience implementation of the aws-sdk-ios `AWSCredentialsProvider` protocol backed
/// by Amplify's Cognito-based Auth plugin.
///
/// - Tag: CredentialsProxy
class CredentialsProxy: NSObject {

    /// - Tag: CredentialsProxyError
    enum Error: Swift.Error {
        case missingCredentialsProvider
        case missingCognitoCredentials
    }

    private let auth: AuthCategoryBehavior

    /// - Tag: CredentialsProxy.init
    init(auth: AuthCategoryBehavior = Amplify.Auth) {
        self.auth = auth
    }

    private func _credentials() async throws -> AWSCore.AWSCredentials {
        let session = try await auth.fetchAuthSession(options: nil)
        guard let provider = session as? AuthAWSCredentialsProvider else {
            throw Error.missingCredentialsProvider
        }

        let credentials = try provider.getAWSCredentials().get()
        guard let cognitoCredentials = credentials as? AuthAWSCognitoCredentials else {
            throw Error.missingCognitoCredentials
        }

        return AWSCredentials(accessKey: cognitoCredentials.accessKeyId,
                              secretKey: cognitoCredentials.secretAccessKey,
                              sessionKey: cognitoCredentials.sessionToken,
                              expiration: cognitoCredentials.expiration)
    }
}

extension CredentialsProxy: AWSCore.AWSCredentialsProvider {

    func credentials() -> AWSTask<AWSCore.AWSCredentials> {
        let source = AWSTaskCompletionSource<AWSCore.AWSCredentials>()
        Task {
            do {
                let credentials = try await _credentials()
                source.set(result: credentials)
            } catch {
                source.set(error: error)
            }
        }
        return source.task
    }

    func invalidateCachedTemporaryCredentials() {}
}
