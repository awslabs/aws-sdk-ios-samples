//
//  APIUpdateMutationUITests.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/8/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import XCTest

class APIUpdateMutationUITests: XCTestCase {
    
    let albumName = UUID().uuidString
    let newName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?
    
    override func setUp() {
        
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.signInWithValidCredentials()
        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)
    }
    
    override func tearDown() {
        
        UIActions.deleteAlbumWith(albumName: newName)
        UIActions.tapSignOut()
    }
    
    func testUpdateMutation() {
        
        // Given valid sign-in, create album mutation succeeds
        // when the user updates the album name text field
        // then verify that update mutation succeeds from the updated album properties
        
        let albumCell = UIElements.collectionViewCell(identifier: newName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: newName)
        
        UIActions.updateAlbumWith(albumName: albumName, newName: newName)
        
        XCTAssertTrue(albumCell.exists)
        XCTAssertTrue(albumNameTextField.exists)
        XCTAssertEqual(albumNameTextField.value as? String, newName)
    }
    
}
