//
//  PhotoCollectionViewCell.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/17/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSS3
import AWSMobileClient
import AWSAppSync

protocol PhotoCollectionViewCellDelegate: class {
    func deletePhoto(cell: PhotoCollectionViewCell)
}

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var photoThumbnail: UIImageView!
    @IBOutlet weak var photoDeleteBackgroundView: UIVisualEffectView!
    @IBOutlet weak var photoThumbnailDownloadProgressView: UIProgressView!

    weak var photoCollectionViewCellDelegate: PhotoCollectionViewCellDelegate?

    var photoId: GraphQLID!
    var accessType: AccessSpecifier!
    var thumbnail: UIImage?
    var editMode: Bool = false {
        didSet {
            photoDeleteBackgroundView.isHidden = !editMode
        }
    }

    var photoImageName: String! {
        didSet {

            // store the actual sized image in s3
            // use only thumbnail to display
            self.photoThumbnailDownloadProgressView.progress = 0.0

            let downloadExpression = AWSS3TransferUtilityDownloadExpression()
            downloadExpression.progressBlock = {(task, progress) in
                DispatchQueue.main.async(execute: {
                    if self.photoThumbnailDownloadProgressView.progress < Float(progress.fractionCompleted) {
                        self.photoThumbnailDownloadProgressView.progress = Float(progress.fractionCompleted)
                    }
                })
            }

            var downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

            downloadCompletionHandler = { (task, URL, data, error) -> Void in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }

                if task.status == .completed {
                    print("Download successful.")
                    DispatchQueue.main.async(execute: {
                        self.photoThumbnail.image = UIImage(data: data!)
                    })
                }
            }

            RemoteStorage.getImageFromBucket(id: self.photoImageName + "_small",
                                             accessType: self.accessType,
                                             downloadExpression: downloadExpression,
                                             downloadCompletionHandler: downloadCompletionHandler)
        }
    }

    @IBAction func deletePhotoDidTap(_ sender: Any) {
        photoCollectionViewCellDelegate?.deletePhoto(cell: self)
    }

}
