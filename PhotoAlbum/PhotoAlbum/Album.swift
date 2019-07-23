//
//  Album.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/15/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSAppSync

//todo: include ownership and sharing

enum AccessSpecifier: String {
    case Public
    case Private
    case Protected
}

struct Album {
    let id: GraphQLID
    let label: String
    var photos: [Photo]
    let accessType: AccessSpecifier

    init(id: GraphQLID, label: String, photos: [Photo], accessType: AccessSpecifier) {
        self.id = id
        self.label = label
        self.photos = photos
        self.accessType = accessType
    }

    init(id: GraphQLID, label: String, accessType: AccessSpecifier) {
        self.init(id: id, label: label, photos: [Photo](), accessType: accessType)
    }

    init(id: GraphQLID, label: String) {
        self.init(id: id, label: label, accessType: AccessSpecifier.Public)
    }

    init(id: GraphQLID) {
        self.init(id: id, label: "", photos: [Photo](), accessType: AccessSpecifier.Public)
    }

    func getAlbumImage() -> String {
        return "album"
    }

    mutating func appendPhoto(photo: Photo) {
        self.photos.append(photo)
    }

    mutating func setPhotos(photos: [Photo]) {
        self.photos = photos
    }

}
