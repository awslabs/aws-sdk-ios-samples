//
//  AlbumCollectionViewCell.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/16/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSAppSync

protocol AlbumCollectionViewCellDelegate: class {

    func deleteAlbum(cell: AlbumCollectionViewCell)
    func updateAlbumName(cell: AlbumCollectionViewCell)
}

class AlbumCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var albumThumbnail: UIImageView!

    @IBOutlet weak var albumTitleField: UITextField!

    @IBOutlet weak var albumDeleteBackgroundView: UIVisualEffectView!

    var albumId: GraphQLID!  //identifier used during addition and deletion of Albums

    weak var albumCollectionViewCellDelegate: AlbumCollectionViewCellDelegate?

    var editMode: Bool = false {
        didSet {
            albumDeleteBackgroundView.isHidden = !editMode
        }
    }

    var albumImageName: String! {
        didSet {
            albumThumbnail.image = UIImage(named: albumImageName)
            albumThumbnail.image?.accessibilityIdentifier = albumTitle + "_img"
            albumThumbnail.image?.isAccessibilityElement = true
            albumDeleteBackgroundView.layer.cornerRadius = albumDeleteBackgroundView.bounds.width/2.0
            albumDeleteBackgroundView.layer.masksToBounds = true
            albumDeleteBackgroundView.isHidden = !editMode
        }
    }

    var albumTitle: String! {
        didSet {
            albumTitleField.text = albumTitle
            albumTitleField.accessibilityIdentifier = albumTitle + "_name"
            albumTitleField.isAccessibilityElement = true
        }
    }

    @IBAction func deleteAlbumDidTap(_ sender: Any) {

        albumCollectionViewCellDelegate?.deleteAlbum(cell: self)
    }

    @IBAction func updateAlbumName(_ sender: Any) {

        albumTitleField.tintColor = UIColor.clear
        albumCollectionViewCellDelegate?.updateAlbumName(cell: self)
    }

}
