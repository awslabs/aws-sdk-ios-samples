//
//  UIActions.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/5/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import XCTest

struct UIActions {
    
    //todo: better handling of secure information
    static var username = "test01"
    static var password = "The#test1"
    static var app: XCUIApplication!
    
    static func launchApp() -> XCUIApplication {
        
        let appInstance: XCUIApplication = XCUIApplication()
        appInstance.launchArguments = ["-StartFromCleanState", "YES"]
        appInstance.launch()
        app = appInstance
        return appInstance
    }
    
    static func tapSignOut() {
        
        let signOutButton = UIElements.AlbumsScreen.signOutButton
        let signOutFound = signOutButton.waitForExistence(timeout: networkTimeout)
        if signOutFound {
            signOutButton.tap()
            let signInScreen = UIElements.SignInScreen.navigationBar
            _ = signInScreen.waitForExistence(timeout: networkTimeout)
        }
    }
    
    static func signInWith(username: String, password: String) {
        
        tapSignOut() // sign out if already signed in
        
        let signInScreen = UIElements.SignInScreen.navigationBar
        _ = signInScreen.waitForExistence(timeout: networkTimeout)
        
        let tablesQuery = app.tables
        let textField = tablesQuery/*@START_MENU_TOKEN@*/.cells.containing(.staticText, identifier: "User Name")/*[[".cells.containing(.staticText, identifier:\"USER NAME\")",".cells.containing(.staticText, identifier:\"User Name\")"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .textField).element
        textField.tap()
        app.typeText(username)
        
        let passwordStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Password"]/*[[".cells.staticTexts[\"Password\"]",".staticTexts[\"Password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        passwordStaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.cells.secureTextFields.containing(.button, identifier: "Show").element/*[[".cells.secureTextFields.containing(.button, identifier:\"Show\").element",".secureTextFields.containing(.button, identifier:\"Show\").element"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/.typeText(password)
        
        UIElements.SignInScreen.signInButton.tap()
        
    }
    
    static func signInWithValidCredentials() {
        
        signInWith(username: username, password: password)
    }
    
    static func createNewAlbumWith(albumName: String, accessType: String) {
        
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        
        _ = UIElements.AlbumsScreen.addAlbumButton.waitForExistence(timeout: uiTimeout)
        UIElements.AlbumsScreen.addAlbumButton.tap()
        UIActions.fillAlbumDetailsWith(albumName: albumName, accessType: accessType)

        _ = albumCell.waitForExistence(timeout: networkTimeout)
        
    }
    
    static func fillAlbumDetailsWith(albumName: String, accessType: String) {
        
        let nameAndAccessAlert = app.alerts["Name and Access"]
        
        _ = nameAndAccessAlert.waitForExistence(timeout: uiTimeout)
        nameAndAccessAlert.collectionViews.textFields["My Album Name"].typeText(albumName)
        nameAndAccessAlert.buttons[accessType].tap()
    }
    
    static func deleteAlbumWith(albumName: String) {
        
        UIElements.AlbumsScreen.editButton.tap()
        
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        albumCell.buttons["CloseIcon"].tap()
        
        UIElements.AlbumsScreen.editDoneButton.tap()
        
    }
    
    static func updateAlbumWith(albumName: String, newName: String) {
        
        let albumCell = UIElements.collectionViewCell(identifier: albumName)
        let albumNameTextField = UIElements.AlbumsScreen.albumNameTextField(albumName: albumName)
        let photosScreenBackButton = UIElements.PhotosScreen.backButton
        
        UIActions.clearAndEnterText(UIElement: albumNameTextField, text: newName)
        albumCell.tap()
        
        _ = photosScreenBackButton.waitForExistence(timeout: uiTimeout)
        photosScreenBackButton.tap()
        _ = UIElements.AlbumsScreen.navigationBar.waitForExistence(timeout: networkTimeout)
    }
    
    static func clearAndEnterText(UIElement: XCUIElement, text: String) {
        
        guard let stringValue = UIElement.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        UIElement.tap()
        
        guard !Array(stringValue).isEmpty else {
            UIElement.typeText(text)
            return
        }
        
        for _ in 0..<Array(stringValue).count {
            UIElement.typeText(XCUIKeyboardKey.delete.rawValue)
        }
        
        UIElement.typeText(text)
    }
}
