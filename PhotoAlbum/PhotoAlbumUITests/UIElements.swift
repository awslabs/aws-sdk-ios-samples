//
//  UIElements.swift
//  PhotoAlbumUITests
//
//  Created by Edupuganti, Phani Srikar on 7/5/19.
//  Copyright © 2019 AWSMobile. All rights reserved.
//

import Foundation
import UIKit
import XCTest

struct UIElements {
    
//    static var app: XCUIApplication {
//        return XCUIApplication()
//    }
    static var app: XCUIApplication {
        return UIActions.app
    }
    
    struct SignInScreen {
        
        static var navigationBar: XCUIElement {
            return app.navigationBars["Sign In"]
        }
        static var signInButton: XCUIElement {
            return app.buttons["Sign In"]
        }
    }
    
    struct AlbumsScreen {
        
        static var navigationBar: XCUIElement {
            return app.navigationBars["Albums"]
        }
        static var addAlbumButton: XCUIElement {
            return navigationBar.buttons["Add"]
        }
        static var signOutButton: XCUIElement {
            return navigationBar.buttons["Sign Out"]
        }
        static var editButton: XCUIElement {
            return navigationBar.buttons["Edit"]
        }
        static var editDoneButton: XCUIElement {
            return navigationBar.buttons["Done"]
        }
        
        static func albumNameTextField(albumName: String) -> XCUIElement {
            return XCUIApplication().collectionViews.textFields[albumName + "_name"]
        }
    }
    
    struct PhotosScreen {
        
        static var navigationBar: XCUIElement {
            return app.navigationBars["Photos"]
        }
        static var backButton: XCUIElement {
            return navigationBar.buttons["Albums"]
        }
        static var addPhotoButton: XCUIElement {
            return navigationBar.buttons["Add"]
        }
        static var addedPhotoCell: XCUIElement {
            return app.collectionViews.children(matching: .cell).element(boundBy: 0).otherElements.containing(.progressIndicator, identifier: "Progress").element
        }
    }
    
    struct PhotoScreen {
        
        static var navigationBar: XCUIElement {
            return app.navigationBars["Photo"]
        }
        static var backButton: XCUIElement {
            return navigationBar.buttons["Photos"]
        }
        static var fullSizeImage: XCUIElement {
            return app.images["fullSizeImage"]
        }
        static var fullSizeImageProgressView: XCUIElement {
            return app/*@START_MENU_TOKEN@*/.progressIndicators["fullSizeImageDownloadProgressView"]/*[[".progressIndicators[\"Progress\"]",".progressIndicators[\"fullSizeImageDownloadProgressView\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        }
    }
    
    static func collectionViewCell(identifier: String!) -> XCUIElement {
        let collectionViewsQuery = app.collectionViews
        return collectionViewsQuery.cells[identifier]
    }
    
}
