//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import SwiftUI

struct AuthView: View {

    @ObservedObject var model = AuthViewModel()

    var body: some View {
        switch model.state {

        case .unknown:
            Text("Peparing user...").onAppear(perform: model.resolveState)
        case .error(let error):
            NavigationStack {
                Text(error.localizedDescription).toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") { model.resolveState() }
                    }
                }
            }

        case .signingIn:
            Text("Signing In...")
        case .signedIn:
            NavigationStack {
                DeviceView().toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sign Out") { model.signOut() }
                    }
                }
            }

        case .signingOut:
            Text("Signing you out...")
        case .signedOut:
            Form {
                TextField("Email:", text: $model.email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                SecureField("Password:", text: $model.password).textInputAutocapitalization(.never)
                HStack {
                    Button("Sign Up") { model.signUp() }.buttonStyle(.bordered)
                    Spacer()
                    Button("Sign In") { model.signIn() }.buttonStyle(.borderedProminent)
                }
            }

        case .signingUp:
            Text("Signing Up...")
        case .signedUpPendingConfirmation:
            Text("Please Confirm Your User")
        case .signedUp:
            NavigationStack {
                DeviceView().toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sign Out") { model.signOut() }
                    }
                }
            }

        }
    }
}
