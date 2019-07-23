//
//  GraphQLAlbumCollectionOperation.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/29/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSAppSync
import AWSMobileClient

class GraphQLAlbumCollectionOperation {

    class func getAlbumsInCollection(_ completion: @escaping ([ListAlbumsQuery.Data.ListAlbum.Item?]?) -> Void) {

        let listAlbumsQueryFilter = ModelAlbumFilterInput(username: ModelStringFilterInput(eq: AWSMobileClient.sharedInstance().username!))
        let listAlbumsQuery = ListAlbumsQuery(filter: listAlbumsQueryFilter)

        AWSServiceManager.appSyncClient?.fetch(query: listAlbumsQuery, cachePolicy: .fetchIgnoringCacheData) { (result, error) in
            if let error = error {
                print(error.localizedDescription ?? "")
                return
            }
            completion(result?.data?.listAlbums?.items)
        }
    }

    class func addAlbum(label: String!, accessType: AccessSpecifier, _ completion: @escaping (GraphQLID) -> Void) {

        let addAlbumInput = CreateAlbumInput(username: AWSMobileClient.sharedInstance().username!, name: label, accesstype: accessType.rawValue)

        AWSServiceManager.appSyncClient?.perform(mutation: CreateAlbumMutation(input: addAlbumInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
                return
            }
            guard result?.errors == nil else {
                print("Error saving the item on server: \(result?.errors)")
                return
            }
            guard let addAlbumResponse = result?.data?.createAlbum else {
                print("Result unexpectedly nil posting a new item")
                return
            }
            print("New item returned from server and stored in local cache, server-provided id: \(addAlbumResponse.id)")
            completion(addAlbumResponse.id)
        }
    }

    class func deleteAlbum(id: GraphQLID!, _ completion: @escaping (GraphQLID) -> Void) {

        let deleteAlbumInput = DeleteAlbumInput(id: id)

        AWSServiceManager.appSyncClient?.perform(mutation: DeleteAlbumMutation(input: deleteAlbumInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
            }
            if let resultError = result?.errors {
                print("Error saving the item on server: \(resultError)")
                return
            }
            guard let deleteAlbumResponse = result?.data?.deleteAlbum else {
                print("Result unexpectedly nil posting a new item")
                return
            }
            print("New item returned from server and stored in local cache, server-provided id: \(deleteAlbumResponse.id)")
            completion(deleteAlbumResponse.id)
        }
    }

    class func updateAlbum(id: GraphQLID!, label: String!, accessType: AccessSpecifier, _ completion: @escaping (GraphQLID?) -> Void) {

        let updateAlbumInput = UpdateAlbumInput(id: id, username: AWSMobileClient.sharedInstance().username!, name: label, accesstype: accessType.rawValue)

        AWSServiceManager.appSyncClient?.perform(mutation: UpdateAlbumMutation(input: updateAlbumInput)) { (result, error) in
            if let error = error as? AWSAppSyncClientError {
                print("Error occurred: \(error.localizedDescription )")
                completion(nil)
                return
            }
            guard result?.errors == nil else {
                print("Error saving the item on server: \(result?.errors)")
                completion(nil)
                return
            }
            guard let updateAlbumResponse = result?.data?.updateAlbum else {
                print("Result unexpectedly nil posting a new item")
                completion(nil)
                return
            }
            print("Updated item returned from server and stored in local cache, server-provided id: \(updateAlbumResponse.id)")
            completion(updateAlbumResponse.id)
        }
    }

}
