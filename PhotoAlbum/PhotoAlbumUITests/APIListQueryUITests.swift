//
//  APIListQueryUITests.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/8/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import XCTest

class APIListQueryUITests: XCTestCase {

    let albumName = UUID().uuidString
    let accessType = "Public"
    var app: XCUIApplication?
    
    override func setUp() {
        
        continueAfterFailure = false
        app = UIActions.launchApp()
        UIActions.signInWithValidCredentials()
        UIActions.createNewAlbumWith(albumName: albumName, accessType: accessType)
        UIActions.tapSignOut()
        UIActions.signInWithValidCredentials()
    }
    
    override func tearDown() {
        
        UIActions.deleteAlbumWith(albumName: albumName)
        UIActions.tapSignOut()
    }
    
    func testListQueryWithFilter() {
        
        // Given valid sign-in, create album mutation, sign-out succeed
        // when the user signs back in
        // then verify that previously created album is fetched
        
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: albumName)
        
        XCTAssertTrue(albumCell.waitForExistence(timeout: 3)) // network time out
        XCTAssertTrue(albumNameTextField.exists)
        XCTAssertEqual(albumNameTextField.value as? String, albumName)
    }
    
}
