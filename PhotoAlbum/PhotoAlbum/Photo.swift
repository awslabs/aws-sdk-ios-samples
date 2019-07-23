//
//  Photo.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/15/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSAppSync

struct Photo {

    let id: GraphQLID
    let name: String
    let bucket: String
    let key: String
    let backedUp: Bool
    let thumbnail: UIImage?

    init(id: GraphQLID, name: String, bucket: String, key: String, backedUp: Bool?, thumbnail: UIImage?) {
        self.id = id
        self.name = name
        self.bucket = bucket
        self.key = key
        if backedUp != nil {
            self.backedUp = backedUp!
        } else {
            self.backedUp = true
        }
        self.thumbnail = thumbnail
    }

}
