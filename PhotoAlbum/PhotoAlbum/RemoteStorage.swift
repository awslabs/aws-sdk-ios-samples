//
//  RemoteStorage.swift
//  PhotoAlbum
//
//  Created by Edupuganti, Phani Srikar on 6/18/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import AWSAuthUI
import AWSAuthCore
import AWSMobileClient
import AWSS3

class RemoteStorage {
    static let bucketName: String = getBucketNameFromAWSConfig()
    static let userIdentityId: String = AWSMobileClient.sharedInstance().identityId!

    class func putImageInBucket(img: UIImage!, id: String!, accessType: AccessSpecifier,
                                uploadExpression: AWSS3TransferUtilityUploadExpression,
                                uploadCompletionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?) {

        let rawImage: Data! = img.pngData()
        guard let transferUtility = AWSServiceManager.transferUtility else {
            print("transfer utility could not be initialized properly")
            return
        }

        transferUtility.uploadData(rawImage,
                                   bucket: bucketName,
                                   key: getKeyFromReference(reference: id, accessType: accessType),
                                   contentType: "image/png",
                                   expression: uploadExpression,
                                   completionHandler: uploadCompletionHandler).continueWith { (task) -> AnyObject? in
                                    if let error = task.error {
                                        print("Error: \(error.localizedDescription)")
                                    }

                                    if task.result != nil {
                                        print("Upload successful.")
                                    }
                                    return nil
        }

    }

    class func getImageFromBucket(id: String!,
                                  accessType: AccessSpecifier,
                                  downloadExpression: AWSS3TransferUtilityDownloadExpression,
                                  downloadCompletionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?) {

        guard let transferUtility = AWSServiceManager.transferUtility else {
            print("transfer utility could not be initialized properly")
            return
        }

        transferUtility.downloadData(fromBucket: bucketName,
                                     key: getKeyFromReference(reference: id, accessType: accessType),
                                    expression: downloadExpression,
                                    completionHandler: downloadCompletionHandler
                                    ).continueWith { (task) -> AnyObject? in
                                        if let error = task.error {
                                            print("Error: \(error.localizedDescription)")
                                        }

                                        if task.result != nil {
                                            print("download success!")
                                        }
                                        return nil
                                    }
    }

    class func getKeyFromReference(reference: String!, accessType: AccessSpecifier!) -> String! {
        return accessType.rawValue.lowercased() + "/" + RemoteStorage.userIdentityId + "/" + reference
    }
    
    class func getBucketNameFromAWSConfig() -> String {
        var defaultBucketName: String = ""
        if let pathToConfigurationFile = Bundle.main.path(forResource: "awsconfiguration", ofType: "json") {
            do {
                let awsConfigData = try Data(contentsOf: URL(fileURLWithPath: pathToConfigurationFile), options: .mappedIfSafe)
                let awsConfigJson = try JSONSerialization.jsonObject(with: awsConfigData, options: .mutableLeaves)
                if let awsConfigJson = awsConfigJson as? [String: AnyObject],
                    let s3TransferUtilityProperties = awsConfigJson["S3TransferUtility"] as? [String: AnyObject] {
                    if let defaultS3Properties = s3TransferUtilityProperties["Default"] as? [String: String] {
                        if let defaultS3BucketName = defaultS3Properties["Bucket"] {
                            defaultBucketName = defaultS3BucketName
                        }
                    }
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return defaultBucketName
    }
}
