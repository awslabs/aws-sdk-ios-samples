//
//  APICreateMutationUITests.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/7/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import XCTest

class APICreateMutationUITests: XCTestCase {
    
    let albumName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?
    
    override func setUp() {
        
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.signInWithValidCredentials()
    }

    override func tearDown() {
        
        UIActions.deleteAlbumWith(albumName: albumName)
        UIActions.tapSignOut()
    }
    
    func testCreateMutation() {
        
        // Given valid sign-in
        // When the user creates an album
        // then verify that create mutation succeeds from the corresponding AlbumCollectionViewCell
        
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: albumName)
        
        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)
        
        XCTAssertTrue(albumCell.exists)
        XCTAssertTrue(albumNameTextField.exists)
        XCTAssertEqual(albumNameTextField.value as? String, albumName)
    }

}
