//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct DeviceView: View {

    @ObservedObject var model = DeviceViewModel()

    var body: some View {
        VStack {
            Spacer()
            Slider(value: $model.currentValue, in: 0...100.0)
            Spacer()
            switch model.state {
            case .disconnected:
                Text("Disconnected")
            case .connecting:
                Text("Connecting...")
            case .connected:
                Text("Connected")
            case .error(let error):
                Text(error.localizedDescription)
                Button("Connect") {
                    model.connect()
                }
            }
        }.onAppear { model.connect() }
    }
}
