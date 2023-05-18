//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSPluginsCore
import AWSCognitoAuthPlugin
import AWSIoT
import AWSMobileClient
import Combine
import Foundation

/// Illustrates connecting to AWS IoT using a p12 certificate.
///
/// Please make sure the following static variables are set before running this sample application:
///
/// * [DeviceCertificateClient.endpoint](x-source-tag://DeviceCertificateClient.endpoint)
/// * [DeviceCertificateClient.region](x-source-tag://DeviceCertificateClient.region)
///
/// - Tag: DeviceCertificateClient
final class DeviceCertificateClient {

    /// Endpoint to use for communicating with AWS IoT
    ///
    /// Get this value by:
    ///
    /// 1. Opening the AWS Console
    /// 2. Navigating to IoT Core
    /// 3. Clicking the **Settings** menu item.
    ///
    /// From there, you should see the **Endpoint** under the **Device data endpointInfo** section.
    ///
    /// Alternatively, you may type to following from the command line:
    ///
    /// ```
    /// aws iot describe-endpoint --endpoint-type iot:Data
    /// ```
    ///
    /// - Tag DeviceCertificateClient.endpoint
    static let endpoint = "changeme"

    /// Region under which the AWS IoT resources have been setup.
    ///
    /// - Tag DeviceCertificateClient.region
    static let region = AWSRegionType.USEast1

    /// Topic to and from which messages will be sent and received.
    ///
    /// - Tag DeviceCertificateClient.topic
    static let topic = "slider"

    enum Error: Swift.Error {
        case missingPlugin
        case missingConfiguration
        case missingAWSIoTManager
        case missingCertificate
        case readingCertificate
        case importingCertificate
        case connectionRefused
        case connectionError
        case protocolError
        case unknown(String)
    }

    private var dataManager: AWSIoTDataManager
    private var manager: AWSIoTManager
    private var iot: AWSIoT

    private let statusSubject: PassthroughSubject<AWSIoTMQTTStatus, Never>
    private let dataSubject: PassthroughSubject<Data, Never>

    let statusPublisher: AnyPublisher<AWSIoTMQTTStatus, Never>
    let dataPublisher: AnyPublisher<Data, Never>

    private init(dataManager: AWSIoTDataManager, manager: AWSIoTManager, iot: AWSIoT) {
        self.dataManager = dataManager
        self.manager = manager
        self.iot = iot
        self.statusSubject = PassthroughSubject()
        self.statusPublisher = statusSubject.eraseToAnyPublisher()
        self.dataSubject = PassthroughSubject()
        self.dataPublisher = dataSubject.eraseToAnyPublisher()
    }

    static func build() async throws -> DeviceCertificateClient {
        let endpoint = AWSEndpoint(urlString: Self.endpoint)
        let credentialsProvider = MissingCredentialsProvider()

        guard let dataManagerConfiguration = AWSServiceConfiguration(region: Self.region,
                                                                     endpoint: endpoint,
                                                                     credentialsProvider: credentialsProvider) else {
            throw Error.missingConfiguration
        }

        let dataManagerKey = UUID().uuidString
        AWSIoTDataManager.register(with: dataManagerConfiguration, forKey: dataManagerKey)
        let dataManager = AWSIoTDataManager(forKey: dataManagerKey)

        let controlPlaneServiceConfiguration = AWSServiceConfiguration(region:Self.region,
                                                                       credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = controlPlaneServiceConfiguration
        guard let manager = AWSIoTManager.default() else {
            throw Error.missingAWSIoTManager
        }
        let iot = AWSIoT.default()
        return DeviceCertificateClient(dataManager: dataManager, manager: manager, iot: iot)
    }

    func connect() throws {
        let certificateId = try Self.loadCertificate()
        let clientId = DeviceInfo.current.identifierForVendor?.uuidString ?? UUID().uuidString
        dataManager.connect(withClientId: clientId, cleanSession: true, certificateId: certificateId) { [weak self] (status) in
            self?.statusSubject.send(status)
        }
        dataManager.subscribe(toTopic: Self.topic, qoS: .messageDeliveryAttemptedAtMostOnce) { [weak self] (payload) -> Void in
            self?.dataSubject.send(payload)
        }
    }

    func disconnect() {
        dataManager.unsubscribeTopic(Self.topic)
        dataManager.disconnect()
    }

    func send(data: Data) {
        dataManager.publishData(data, onTopic: Self.topic, qoS: .messageDeliveryAttemptedAtMostOnce)
    }

    private static func loadCertificate() throws -> String {
        guard let certURL = Bundle.main.url(forResource: "identity", withExtension: "p12") else {
            throw Error.missingCertificate
        }
        let certificateId = certURL.lastPathComponent

        // If the PKCS12 file requires a passphrase, you'll need to provide that
        // here; this code is written to expect that the PKCS12 file will not
        // have a passphrase.
        guard let data = try? Data(contentsOf: certURL) else {
            throw Error.readingCertificate
        }

        let passPhrase = ""
        guard AWSIoTManager.importIdentity(fromPKCS12Data: data, passPhrase:passPhrase, certificateId:certificateId) else {
            throw Error.importingCertificate
        }

        return certificateId
    }

    /// This class exists because a `AWSCredentialsProvider` is needed in order to create a
    /// `AWSServiceConfiguration`. However, this is not used for the certificate-based connection
    /// established here.
    ///
    /// - Tag: MissingCredentialsProvider
    internal class MissingCredentialsProvider: NSObject, AWSCore.AWSCredentialsProvider {

        func credentials() -> AWSTask<AWSCore.AWSCredentials> {
            enum Error: Swift.Error {
                case missingCredentials
            }
            return .init(error: Error.missingCredentials)
        }

        func invalidateCachedTemporaryCredentials() {
        }
    }


}
