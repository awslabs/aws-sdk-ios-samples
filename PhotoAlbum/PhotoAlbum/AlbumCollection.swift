//
//  AlbumCollection.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/16/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSAppSync

struct AlbumCollection {

    let username: String
    let albums: [Album]

    init(username: String, albums: [Album]) {
        self.username = username
        self.albums = albums
    }

    init(username: String) {
        self.init(username: username, albums: [Album]())
    }
}
