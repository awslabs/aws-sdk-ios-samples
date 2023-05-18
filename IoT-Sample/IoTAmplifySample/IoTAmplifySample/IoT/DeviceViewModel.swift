//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import AWSCognitoAuthPlugin
import AWSIoT
import AWSMobileClient
import Combine
import Foundation

@MainActor
final class DeviceViewModel: ObservableObject {

    enum State {
        case disconnected
        case connecting
        case connected
        case error(Error)
    }

    enum ConnectionError: Error {
        case connectionRefused
        case connectionError
        case protocolError
        case unknown(String)
    }

    enum DataError: Error {
        case nonUTF8(data: Data)
    }

    @Published var state: State = .disconnected
    @Published var currentValue: Double = 50 {
        didSet {
            currentValueDidChange()
        }
    }
    @Published var dataError: Error?

    private var client: DeviceCertificateClient? {
        willSet {
            client?.disconnect()
        }
        didSet {
            self.statusSubscription = client?.statusPublisher
                .receive(on: DispatchQueue.main).sink { [weak self] status in
                self?.handle(status: status)
            }
            self.dataSubscription = client?.dataPublisher
                .receive(on: DispatchQueue.main).sink { [weak self] data in
                self?.handle(data: data)
            }
        }
    }

    private var statusSubscription: Combine.Cancellable? {
        willSet {
            statusSubscription?.cancel()
        }
    }

    private var dataSubscription: Combine.Cancellable? {
        willSet {
            dataSubscription?.cancel()
        }
    }

    private var dataSendBounceTimer: Timer? {
        willSet {
            dataSendBounceTimer?.invalidate()
        }
    }

    func connect() {
        Task {
            do {
                // You may use DeviceCertificateClient or DeviceWebSocketClient,
                // depending on your setup on AWS IoT.
                let client = try await DeviceCertificateClient.build()
                self.client = client
                Task.detached {
                    try client.connect()
                }
            } catch {
                self.state = .error(error)
            }
        }
    }

    func disconnect() {
        self.client = nil
    }

    private func handle(status: AWSIoTMQTTStatus) {
        switch status {
        case .connecting:
            self.state = .connecting
        case .connected:
            self.state = .connected
        case .disconnected:
            self.state = .disconnected
        case .connectionRefused:
            self.state = .error(ConnectionError.connectionRefused)
        case .connectionError:
            self.state = .error(ConnectionError.connectionError)
        case .protocolError:
            self.state = .error(ConnectionError.protocolError)
        default:
            self.state = .error(ConnectionError.unknown("Unsupported AWSIoTMQTTStatus: \(status.rawValue)"))
        }
    }

    private func handle(data: Data) {
        if dataSendBounceTimer != nil {
            /// Client device is the system of record and is in the process of changing
            return
        }

        guard let integerString = String(data: data, encoding: .utf8) else {
            self.dataError = DataError.nonUTF8(data: data)
            return
        }
        do {
            let value = try Double(integerString, format: .number)
            if value != self.currentValue {
                self.currentValue = value
            }
        } catch {
            self.dataError = error
        }
    }

    private func currentValueDidChange() {
        guard let client = self.client else {
            print("Not connected")
            return
        }

        // Wait for the user to stop changing for a second in order to avoid an
        // infinite cycle of changes.
        self.dataSendBounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self] (_) in
            Task { @MainActor [weak self] in
                self?.dataSendBounceTimer = nil
            }
        })

        let string = currentValue.description
        let data = Data(string.utf8)
        client.send(data: data)
    }

}
