//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct RootView: View {

    @ObservedObject var model = RootViewModel()

    var body: some View {
        switch model.state {
        case .configuring:
            SplashView().onAppear(perform: model.configure)
        case .configured:
            AuthView()
        case .error(let error):
            Text(error.localizedDescription)
        }
    }

}
