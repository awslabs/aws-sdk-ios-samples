//
//  AlbumCollectionViewController.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/16/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSAppSync
import AWSMobileClient

class AlbumCollectionViewController: UICollectionViewController {

    var albumCollection: [Album]!
    var selectedAlbum: Album!

    struct StoryBoard {
        static let albumCell = "AlbumCollectionViewCell"
        static let albumToPhotoSegue = "AlbumToPhotoSegue"
    }

    @IBOutlet weak var btnAddAlbum: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.leftBarButtonItem = editButtonItem
    }

    // MARK: - specify UICollectionView Data Source

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumCollection.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currentAlbumCell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryBoard.albumCell,
                                                                  for: indexPath) as! AlbumCollectionViewCell
        currentAlbumCell.albumTitle = albumCollection[indexPath.item].label
        currentAlbumCell.albumId = albumCollection[indexPath.item].id
        currentAlbumCell.albumCollectionViewCellDelegate = self
        currentAlbumCell.editMode = false
        currentAlbumCell.accessibilityIdentifier = albumCollection[indexPath.item].label
        //currentAlbumCell.isAccessibilityElement = true
        currentAlbumCell.albumImageName = albumCollection[indexPath.item].getAlbumImage()
        return currentAlbumCell
    }

    @IBAction func addAlbumDidTap(_ sender: Any) {

        presentAccessSpecifierAlert()
    }

    private func presentAccessSpecifierAlert() {
        let accessSpecifierAlert = UIAlertController(title: "Name and Access", message: "Choose Access", preferredStyle: .alert)

        accessSpecifierAlert.addTextField { (textField) in
            textField.placeholder = "My Album Name"
        }
        let publicAction = UIAlertAction(title: "Public", style: .default) {(_) in
            self.addAlbumUtil(accessType: AccessSpecifier.Public, label: accessSpecifierAlert.textFields?.first?.text)
        }
        let privateAction = UIAlertAction(title: "Private", style: .default) {(_) in
            self.addAlbumUtil(accessType: AccessSpecifier.Private, label: accessSpecifierAlert.textFields?.first?.text)
        }
        let protectedAction = UIAlertAction(title: "Protected", style: .default) {(_) in
            self.addAlbumUtil(accessType: AccessSpecifier.Protected, label: accessSpecifierAlert.textFields?.first?.text)
        }
        accessSpecifierAlert.addAction(publicAction)
        accessSpecifierAlert.addAction(privateAction)
        accessSpecifierAlert.addAction(protectedAction)
        present(accessSpecifierAlert, animated: true, completion: nil)
    }

    private func addAlbumUtil(accessType: AccessSpecifier, label: String?) {

        let numberAlbumsPresent = albumCollection.count
        var newAlbumLabel: String!
        if label == nil || label == "" {
            newAlbumLabel = AWSServiceManager.getTimeStampForTitle()
        } else {
            newAlbumLabel = label
        }
        var newAlbum: Album!

        // Todo: Use a Data Store to which both UI and Data Layers confirm to
        // for better handling of concurrency
        let addAlbumHandler: (GraphQLID) -> Void = { (albumId) in
            newAlbum = Album(id: albumId, label: newAlbumLabel, accessType: accessType)
            // update the local album Collection
            self.albumCollection.append(newAlbum)

            // update the UI -- AlbumCollectionView
            let addIndex = IndexPath(item: numberAlbumsPresent, section: 0)
            self.collectionView?.insertItems(at: [addIndex])
        }

        GraphQLAlbumCollectionOperation.addAlbum(label: newAlbumLabel, accessType: accessType, addAlbumHandler)
    }

    @IBAction func signOutTap(_ sender: Any) {
        AWSServiceManager.signOut(global: true, parentViewController: self)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        btnAddAlbum.isEnabled = !editing

        if let indexPaths = self.collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let currAlbumCell = self.collectionView?.cellForItem(at: indexPath) as? AlbumCollectionViewCell {
                    currAlbumCell.editMode = editing
                }
            }
        }
    }

    //Todo: do not wait for data fetch. Do something in UI -- talk to others
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var photos = [Photo]()

        guard let currAlbumCell = collectionView.cellForItem(at: indexPath) as? AlbumCollectionViewCell,
              let selectedAlbumId = currAlbumCell.albumId else {
                print("Could not fetch albumID for selected Album")
                return
        }

        let getSelectedAlbumHandler: (GetAlbumQuery.Data.GetAlbum?) -> Void = { (album) in
            guard let album = album else {
                print("Could not fetch selected album")
                return
            }

            if let photoItems = album.photos?.items?.compactMap({$0}) {
                photoItems.forEach { item in
                    print("inside getSelectedAlbum completion handler")
                    let vPhoto = Photo(id: (item.id), name: item.name, bucket: item.bucket, key: item.key, backedUp: true, thumbnail: nil)
                    photos.append(vPhoto)
                }
            }

            self.selectedAlbum = Album(id: selectedAlbumId, label: album.name, photos: photos, accessType: AccessSpecifier(rawValue: album.accesstype)!)
            self.performSegue(withIdentifier: StoryBoard.albumToPhotoSegue, sender: self)
        }

        GraphQLPhotoCollectionOperation.getSelectedAlbum(id: selectedAlbumId, getSelectedAlbumHandler)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoard.albumToPhotoSegue {
            let photoCollectionViewController = segue.destination as! PhotoCollectionViewController
            photoCollectionViewController.selectedAlbum = self.selectedAlbum
        }
    }
}

extension AlbumCollectionViewController: AlbumCollectionViewCellDelegate {
    func deleteAlbum(cell: AlbumCollectionViewCell) {
        if let indexPath = self.collectionView?.indexPath(for: cell) {

            let deleteAlbumHandler: (GraphQLID) -> Void = { (albumId) in
                // update the local albumCollection object
                guard let deleteIndex = self.albumCollection.firstIndex(where: {$0.id == albumId}) else {
                    self.collectionView.deleteItems(at: [indexPath])
                    print("albumId not found in data store")
                    return
                }
                self.albumCollection.remove(at: deleteIndex)
                self.collectionView.deleteItems(at: [indexPath])
            }
            GraphQLAlbumCollectionOperation.deleteAlbum(id: cell.albumId, deleteAlbumHandler)
        }
    }

    func updateAlbumName(cell: AlbumCollectionViewCell) {
        print("album edit end triggered")
        GraphQLAlbumCollectionOperation.updateAlbum(id: cell.albumId, label: cell.albumTitleField.text, accessType: selectedAlbum.accessType, { (updatedAlbumId) in
            guard updatedAlbumId != nil else {
                    cell.albumTitleField.text = cell.albumTitle
                    print("album name could not be editted")
                    return
                }
            let newText = cell.albumTitleField.text ?? ""

            cell.albumTitle = newText
            cell.accessibilityIdentifier = newText
            cell.albumTitleField.accessibilityIdentifier = newText + "_name"
            })
    }
}
