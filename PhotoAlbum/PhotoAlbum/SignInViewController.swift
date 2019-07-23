//
//  ViewController.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/15/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import UIKit
import AWSMobileClient
import AWSAuthUI
import AWSAuthCore
import AWSS3
import AWSAppSync

class SignInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        showSignIn()
    }

    func showSignIn() {
        AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!,
                                                    signInUIOptions: SignInUIOptions(
                                                    canCancel: false,
                                                    logoImage: UIImage(named: "AppLogo"),
                                                    backgroundColor: UIColor.black)) {(signInState, error) in
                guard error == nil else {
                    print("error logging in: \(error!.localizedDescription)")
                    return
                }

                guard let signInState = signInState else {
                    print("signInState unexpectedly empty in \(#function)")
                    return
                }

                switch signInState {
                case .signedIn:
                    AWSServiceManager.signInHandler(parentViewController: self)
                    //AWSServiceManager.initializeMobileClient()
                default: return
                }
        }
    }
}
