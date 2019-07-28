//
//  StorageDownloadTests.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/4/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import XCTest
import AWSMobileClient
import AWSS3

class StoragePublicDownloadUITests: XCTestCase {
    
    let albumName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?
    
    override func setUp() {
        continueAfterFailure = false
        app = UIActions.launchApp()
        UtilitiesForStorageUITests.setupDownload(albumName: albumName, accessType: accessType)
    }
    
    override func tearDown() {
        UtilitiesForStorageUITests.teardownDownload(albumName: albumName)
    }
    
    func testS3DownloadPublicBucket() {
        
        // Given valid sign-in, create album mutation succeeds, user uploads a picture
        // when the user requests for full-size image
        // then verify that downloading full size image from S3 succeeds
        
        let fullSizeImage = UIElements.PhotoScreen.fullSizeImage
        let fullSizeImageProgress = UIElements.PhotoScreen.fullSizeImageProgressView
        UtilitiesForStorageUITests.downloadFullSizeImage()
        
        XCTAssertTrue(fullSizeImage.exists)
        XCTAssertEqual(fullSizeImageProgress.value as? String, "100%")
    }
    
}

/*class DownloadPrivateBucket: XCTestCase {
    
    let albumName = UUID().uuidString
    let accessType = "Private"
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
        
        StorageUITests.setupDownload(albumName: albumName, accessType: accessType)
    }
    
    override func tearDown() {
        StorageUITests.teardownDownload(albumName: albumName)
    }
    
    func testS3DownloadPrivateBucket() {
        
        StorageUITests.downloadFullSizeImage()
        let fullSizeImage = UIElements.fullSizeImage()
        let fullSizeImageProgress = UIElements.fullSizeImageProgressView()
        
        XCTAssertTrue(fullSizeImage.exists)
        XCTAssertEqual(fullSizeImageProgress.value as? String, "100%")
    }
    
}

class DownloadProtectedBucket: XCTestCase {
    
    let albumName = UUID().uuidString
    let accessType = "Protected"
    let app = XCUIApplication()
    
    override func setUp() {
        continueAfterFailure = false
        app.launch()
        
        StorageUITests.setupDownload(albumName: albumName, accessType: accessType)
    }
    
    override func tearDown() {
        StorageUITests.teardownDownload(albumName: albumName)
    }
    
    func testS3DownloadProtectedBucket() {
        
        StorageUITests.downloadFullSizeImage()
        let fullSizeImage = UIElements.fullSizeImage()
        let fullSizeImageProgress = UIElements.fullSizeImageProgressView()
        
        XCTAssertTrue(fullSizeImage.exists)
        XCTAssertEqual(fullSizeImageProgress.value as? String, "100%")
    }
    
}
*/
