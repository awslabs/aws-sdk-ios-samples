//
//  ExpandPhotoViewController.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/17/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSS3

class ExpandPhotoViewController: UIViewController {

    @IBOutlet weak var expandPhotoImageView: UIImageView!
    @IBOutlet weak var expandPhotoProgressView: UIProgressView!
    var selectedPhoto: Photo!
    var accessType: AccessSpecifier!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Photo"
        displayFullSizeImage()

    }

    private func displayFullSizeImage() {

        self.expandPhotoProgressView.progress = 0.0
        self.expandPhotoProgressView.accessibilityIdentifier = "fullSizeImageDownloadProgressView"
        let downloadExpression = AWSS3TransferUtilityDownloadExpression()
        downloadExpression.progressBlock = {(task, progress) in
            DispatchQueue.main.async(execute: {
                if self.expandPhotoProgressView.progress < Float(progress.fractionCompleted) {
                    self.expandPhotoProgressView.progress = Float(progress.fractionCompleted)
                }
            })
        }

        var downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

        downloadCompletionHandler = { (task, URL, data, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }

            if task.status == .completed {
                print("Download full size image successful.")
                DispatchQueue.main.async(execute: { //error checking
                    self.expandPhotoImageView.image = UIImage(data: data!)
                    self.expandPhotoImageView.accessibilityIdentifier = "fullSizeImage"
                })
            }
        }

        RemoteStorage.getImageFromBucket(id: selectedPhoto.key + "_big", accessType: accessType,
                                         downloadExpression: downloadExpression,
                                         downloadCompletionHandler: downloadCompletionHandler)
    }
}
