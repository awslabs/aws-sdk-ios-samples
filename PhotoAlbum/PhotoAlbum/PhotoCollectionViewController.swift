//
//  PhotoCollectionViewController.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/17/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSAppSync
import AWSS3

class PhotoCollectionViewController: UICollectionViewController {
    var selectedAlbum: Album!
    var selectedPhoto: Photo!

    struct StoryBoard {
        static let photoCell = "PhotoCollectionViewCell"
        static let expandPhotoSegue = "ExpandPhotoSegue"
    }

    @IBOutlet weak var btnAddPhoto: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }

    // MARK: - specify UICollectionView Data Source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAlbum.photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoard.photoCell, for: indexPath) as! PhotoCollectionViewCell

        currentPhotoCell.photoId = selectedAlbum.photos[indexPath.item].id
        currentPhotoCell.accessType = selectedAlbum.accessType
        currentPhotoCell.thumbnail = selectedAlbum.photos[indexPath.item].thumbnail
        currentPhotoCell.photoImageName = selectedAlbum.photos[indexPath.item].key
        currentPhotoCell.photoCollectionViewCellDelegate = self
        currentPhotoCell.editMode = false
        return currentPhotoCell
    }

    @IBAction func addPhotoDidTap(_ sender: Any) {

        let numberPhotosPresent = selectedAlbum.photos.count

        //Todo: Implement selection from device
        // Randomly pick from the Assets 
        let availableAssets: [String] = ["pic1", "pic2", "pic3", "pic4"]
        let randomIndex = Int(arc4random_uniform(UInt32(availableAssets.count)))
        let givenImage: UIImage! = UIImage(named: availableAssets[randomIndex])

        let newPhotoName: String! = AWSServiceManager.getTimeStampForTitle()
        let newPhotoBucket: String! = RemoteStorage.bucketName
        var newPhoto: Photo!

        let thumbnailSize = CGSize(width: 200.0, height: 200.0)

        guard let thumbnail = generateThumbnail(image: givenImage, size: thumbnailSize) else {
            print("compression failed to generate thumbnail. Click to see full size picture.")
            return
        }

        let addPhotoHandler: (GraphQLID) -> Void = { (photoId) in
            newPhoto = Photo(id: photoId, name: newPhotoName, bucket: newPhotoBucket,
                             key: newPhotoName, backedUp: true, thumbnail: thumbnail)

            //update the local albumCollection object
            self.selectedAlbum.appendPhoto(photo: newPhoto)

            //update the UI -- AlbumCollectionView
            let addIndexPhoto = IndexPath(item: numberPhotosPresent, section: 0)
            self.collectionView?.insertItems(at: [addIndexPhoto])
        }

        let uploadExpression = AWSS3TransferUtilityUploadExpression()

        var uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        uploadCompletionHandler = { (task, error) -> Void in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }

            if task.status == .completed {
                print("Upload successful.")
                DispatchQueue.main.async(execute: {
                    GraphQLPhotoCollectionOperation.addPhoto(name: newPhotoName,
                                                             bucket: newPhotoBucket,
                                                             key: newPhotoName,
                                                             albumId: self.selectedAlbum.id,
                                                             addPhotoHandler)
                })
            }
        }

        // back up in S3

        RemoteStorage.putImageInBucket(img: thumbnail,
                                       id: newPhotoName + "_small",
                                       accessType: selectedAlbum.accessType,
                                       uploadExpression: uploadExpression,
                                       uploadCompletionHandler: uploadCompletionHandler)
        RemoteStorage.putImageInBucket(img: givenImage,
                                       id: newPhotoName + "_big", //get image name/ get image thumbnail name
                                       accessType: selectedAlbum.accessType,
                                       uploadExpression: AWSS3TransferUtilityUploadExpression(),
                                       uploadCompletionHandler: nil)
    }

    @IBAction func btnSignOutTap(_ sender: Any) {
        AWSServiceManager.signOut(global: true, parentViewController: self)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        btnAddPhoto.isEnabled = !editing

        if let indexPaths = self.collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let currPhotoCell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                    currPhotoCell.editMode = editing
                }
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currPhotoCell = self.collectionView?.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
            var selectedPhotos = selectedAlbum.photos
            for selectedIndex in 0..<selectedPhotos.count {
                if selectedPhotos[selectedIndex].id == currPhotoCell.photoId {
                    selectedPhoto = selectedPhotos[selectedIndex]
                    break
                }
            }
        }
        performSegue(withIdentifier: StoryBoard.expandPhotoSegue, sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.expandPhotoSegue {
            let expandPhotoViewController = segue.destination as! ExpandPhotoViewController
            expandPhotoViewController.selectedPhoto = selectedPhoto
            expandPhotoViewController.accessType = selectedAlbum.accessType
        }
    }

    public func generateThumbnail(image: UIImage, size: CGSize) -> UIImage? {
        let originalSize = image.size

        let widthRatio  = size.width  / originalSize.width
        let heightRatio = size.height / originalSize.height
        let compressionRatio = min(widthRatio, heightRatio)
        let compressedSize = CGSize(width: originalSize.width * compressionRatio, height: originalSize.height * compressionRatio)
        let rect = CGRect(x: 0, y: 0, width: compressedSize.width, height: compressedSize.height)
        UIGraphicsBeginImageContextWithOptions(compressedSize, false, 1.0)
        image.draw(in: rect)
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //displayCompressionRatio(givenImage: image, thumbnail: thumbnailImage)
        return thumbnailImage
    }

    public func displayCompressionRatio(givenImage: UIImage, thumbnail: UIImage) {
        let thumbnailCGImage: CGImage! = thumbnail.cgImage
        let compressedThumbnailSize = thumbnailCGImage.height * thumbnailCGImage.bytesPerRow
        let originalCGImage: CGImage! = givenImage.cgImage
        let originalImageSize = originalCGImage.height * originalCGImage.bytesPerRow

        print("**** Image compressed from \(originalImageSize) to \(compressedThumbnailSize) *****")
    }
}

extension PhotoCollectionViewController: PhotoCollectionViewCellDelegate {
    func deletePhoto(cell: PhotoCollectionViewCell) {
        if let indexPath = self.collectionView?.indexPath(for: cell) {

            let deletePhotoHandler: (GraphQLID) -> Void = { (photoId) in
                //update the local albumCollection object
                var selectedPhotos = self.selectedAlbum.photos
                guard let deleteIndex = selectedPhotos.firstIndex(where: {$0.id == photoId}) else {
                    cell.photoThumbnail.image = nil
                    self.collectionView.deleteItems(at: [indexPath])
                    print("photoId not found in data store")
                    return
                }
                selectedPhotos.remove(at: deleteIndex)
                self.selectedAlbum.setPhotos(photos: selectedPhotos)
                cell.photoThumbnail.image = nil
                self.collectionView.deleteItems(at: [indexPath])
                // todo: call function to delete image from bucket
                // currently does not exist using transferutility
            }
            GraphQLPhotoCollectionOperation.deletePhoto(id: cell.photoId, deletePhotoHandler)
        }
    }
}
