//
//  GraphQLPhotoCollectionOperation.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/20/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSAppSync
import AWSMobileClient

class GraphQLPhotoCollectionOperation {

    class func getSelectedAlbum(id: GraphQLID, _ completion: @escaping (GetAlbumQuery.Data.GetAlbum?) -> Void) {

        let getSelectedAlbumQuery = GetAlbumQuery(id: id)
        AWSServiceManager.appSyncClient?.fetch(query: getSelectedAlbumQuery, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            completion(result?.data?.getAlbum)
        }
    }

    class func addPhoto(name: String!, bucket: String!, key: String!, albumId: GraphQLID, _ completion: @escaping (GraphQLID) -> Void) {
        let addPhotoInput = CreatePhotoInput(name: name, bucket: bucket, key: key, photoAlbumId: albumId)

        AWSServiceManager.appSyncClient?.perform(mutation: CreatePhotoMutation(input: addPhotoInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            guard let addPhotoResponse = result?.data?.createPhoto else {
                print("Result unexpectedly nil posting a new item")
                return
            }
            print("New item returned from server and stored in local cache, server-provided id: \(addPhotoResponse.id)")
            completion(addPhotoResponse.id)
        }
    }

    class func deletePhoto(id: GraphQLID!, _ completion: @escaping (GraphQLID) -> Void) {
        let deletePhotoInput = DeletePhotoInput(id: id)

        AWSServiceManager.appSyncClient?.perform(mutation: DeletePhotoMutation(input: deletePhotoInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            guard let deletePhotoResponse = result?.data?.deletePhoto else {
                print("Result unexpectedly nil posting a new item")
                return
            }
            print("New item returned from server and stored in local cache, server-provided id: \(deletePhotoResponse.id)")
            completion(deletePhotoResponse.id)
        }
    }

}
