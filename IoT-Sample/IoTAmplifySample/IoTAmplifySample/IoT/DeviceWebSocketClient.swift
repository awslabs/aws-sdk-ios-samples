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

/// Illustrates connecting to AWS IoT using a web socket.
///
/// Please make sure the following static variables are set before running this sample application:
///
/// * [DeviceWebSocketClient.endpoint](x-source-tag://DeviceWebSocketClient.endpoint)
/// * [DeviceWebSocketClient.region](x-source-tag://DeviceWebSocketClient.region)
///
/// - Tag: DeviceWebSocketClient
final class DeviceWebSocketClient {

    /// Endpoint to use for communicating with AWS IoT
    ///
    /// Change this value by:
    /// * Opening the AWS Console
    /// * Navigating to IoT
    ///
    /// - Tag DeviceWebSocketClient.endpoint
    static let endpoint = "https://a14altnl6978mg-ats.iot.us-east-1.amazonaws.com"

    /// Region under which the AWS IoT resources have been setup.
    ///
    /// - Tag DeviceWebSocketClient.region
    static let region = AWSRegionType.USEast1

    /// Topic to and from which messages will be sent and received.
    ///
    /// - Tag DeviceWebSocketClient.topic
    static let topic = "slider"

    enum Error: Swift.Error {
        case missingPlugin
        case missingConfiguration
        case missingAWSIoTManager
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

    static func build() async throws -> DeviceWebSocketClient {
        let endpoint = AWSEndpoint(urlString: Self.endpoint)
        let credentialsProvider = CredentialsProxy()

        guard let dataManagerConfiguration = AWSServiceConfiguration(region: Self.region,
                                                                 endpoint: endpoint,
                                                                 credentialsProvider: credentialsProvider) else {
            throw Error.missingConfiguration
        }

        let dataManagerKey = UUID().uuidString
        AWSIoTDataManager.register(with: dataManagerConfiguration, forKey: dataManagerKey)
        let dataManager = AWSIoTDataManager(forKey: dataManagerKey)

        let controlPlaneServiceConfiguration = AWSServiceConfiguration(region:Self.region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = controlPlaneServiceConfiguration
        guard let manager = AWSIoTManager.default() else {
            throw Error.missingAWSIoTManager
        }
        let iot = AWSIoT.default()
        return DeviceWebSocketClient(dataManager: dataManager, manager: manager, iot: iot)
    }

    func connect() throws {
        let clientId = DeviceInfo.current.identifierForVendor?.uuidString ?? UUID().uuidString
        dataManager.connectUsingWebSocket(withClientId: clientId, cleanSession: true) { [weak self] (status) in
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

}
