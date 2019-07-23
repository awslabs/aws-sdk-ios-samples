//
//  AWSServiceManager.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/24/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import AWSMobileClient
import AWSAppSync
import AWSS3

class AWSServiceManager {

    static let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static var appSyncClient: AWSAppSyncClient?
    static var transferUtility: AWSS3TransferUtility?

    class func signOut(global: Bool, parentViewController: UIViewController?) {
        AWSMobileClient.sharedInstance().signOut(options: SignOutOptions(signOutGlobally: global)) { (error) in
            guard error == nil else {
                print("Error: \(error.debugDescription)")
                return
            }
            presentSignInController(parentViewController: parentViewController)
        }
    }

    class func initializeMobileClient() {
        //AWSMobileClient.sharedInstance().signOut()
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                return
            }

            if let userState = userState {
                switch userState {
                case .signedIn:
                    signInHandler(parentViewController: nil)
                default: presentSignInController(parentViewController: nil)
                }
            }
        }
    }

    class func initializeAppSyncClient() {
        do {
            // Todo: TransferUtility conformance to S3ObjectManager protocol

            // AppSync configuration & client initialization
            // default configuration writes cache to the disk
            let cacheConfiguration = try AWSAppSyncCacheConfiguration()
            let appSyncServiceConfig = try AWSAppSyncServiceConfig()
            let appSyncConfig = try AWSAppSyncClientConfiguration(appSyncServiceConfig: appSyncServiceConfig,
                                                                  userPoolsAuthProvider: AWSMobileClient.sharedInstance(),
                                                                  cacheConfiguration: cacheConfiguration)
            appSyncClient = try AWSAppSyncClient(appSyncConfig: appSyncConfig)

            // Set id as the cache key for objects.
            appSyncClient?.apolloClient?.cacheKeyForObject = { $0["id"] }
        } catch {
            print("Error initializing appsync client. \(error)")
        }
    }

    class func initializeTransferUtility() {
        transferUtility = AWSS3TransferUtility.default()
    }

    class func initializeAWSInstances() {
        initializeMobileClient()
    }

    //Todo: have a user state listener

    class func signInHandler(parentViewController: UIViewController?) {
        initializeTransferUtility()
        initializeAppSyncClient()

        AWSMobileClient.sharedInstance().credentials().continueWith { (_) -> Any? in
            print(AWSMobileClient.sharedInstance().identityId)
            return nil
        }

        /*DispatchQueue.global().async(execute: {
            AWSMobileClient.sharedInstance().getIdentityId().continueWith { (task) -> AnyObject? in
            
                
                if let error = task.error {
                    print("Error: \(error.localizedDescription)")
                }
                
                if task.result != nil {
                    print("task success!")
                }
                return nil
            }
        })*/
        print("logged in!")

        /*AWSMobileClient.sharedInstance().getAWSCredentials { (credentials, error) in
            if let error = error {
                print("\(error.localizedDescription)")
            } else if let credentials = credentials {
                print(credentials.accessKey)
            }
         }*/

        var albums = [Album]()

        let listAlbumsHandler: ([ListAlbumsQuery.Data.ListAlbum.Item?]?) -> Void = { (albumItems) in
            if let albumItems = albumItems?.compactMap({$0}) {
                albumItems.forEach { item in
                    print("inside getAlbums completion handler")
                    var vAlbum = Album(id: item.id, label: item.name, accessType: AccessSpecifier(rawValue: item.accesstype)!)
                    albums.append(vAlbum)
                }
            }
            AWSServiceManager.presentAlbumCollectionViewController(parentViewController: parentViewController, albumCollection: albums)
        }
        GraphQLAlbumCollectionOperation.getAlbumsInCollection(listAlbumsHandler)
    }

    class func presentSignInController(parentViewController: UIViewController?) {

        let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController

        presentViewController(viewController: signInViewController, parentViewController: parentViewController)
    }

    class func presentAlbumCollectionViewController(parentViewController: UIViewController?, albumCollection: [Album]) {

        let albumCollectionViewController = storyBoard.instantiateViewController(withIdentifier: "AlbumCollectionViewController") as! AlbumCollectionViewController
        albumCollectionViewController.albumCollection = albumCollection

        presentViewController(viewController: albumCollectionViewController, parentViewController: parentViewController)

    }

    class func presentViewController(viewController: UIViewController, parentViewController: UIViewController?) {

        let navigationController = UINavigationController(rootViewController: viewController)

        if let parentViewController = parentViewController {
            parentViewController.navigationController!.present(navigationController,
                                                               animated: true,
                                                               completion: nil)
        } else {
            appDelegate.window?.rootViewController!.present(navigationController,
                                                            animated: true,
                                                            completion: nil)
        }
    }

    class func getTimeStampForTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }

}

// extension to use MobileClient as the default Auth Provider

extension AWSMobileClient: AWSCognitoUserPoolsAuthProviderAsync {
    public func getLatestAuthToken(_ callback: @escaping (String?, Error?) -> Void) {
        getTokens { (tokens, error) in
            if error != nil {
                callback(nil, error)
            } else {
                callback(tokens?.idToken?.tokenString, nil)
            }
        }
    }
}
