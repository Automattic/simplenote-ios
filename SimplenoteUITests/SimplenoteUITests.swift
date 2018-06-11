//
//  SimplenoteUITests.swift
//  SimplenoteUITests
//
//  Created by Xue Qin on 1/31/18.
//  Copyright © 2018 Automattic. All rights reserved.
//

import XCTest

class SimplenoteUITests: XCTestCase {
    
    let app = XCUIApplication()
    let username = "ui.privacy.utsa4@gmail.com"
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        if app.staticTexts["Welcome to Simplenote"].exists {
            welcome()
            signUp()
            logout()
            signInWithError()
            
        } else {
            // do nothing
        }

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func scrollToElement(element: XCUIElement)
    {
        while element.exists == false
        {
            app.swipeUp()
        }
        
        sleep(3)
    }
    
    func logout() {
        
        app.navigationBars["SPNoteListView"].otherElements["Sidebar"].tap()
        app.buttons["Settings"].tap()
        app.tables.staticTexts["Sign Out"].tap()
        sleep(2)
        
    }
    
    
    
    func login() {
        let tablesQuery = app.tables
        tablesQuery.buttons["SIGN IN »"].tap()
        let emailfield = tablesQuery.textFields.matching(identifier: "email@email.com").element(boundBy: 0)
        let password = tablesQuery.secureTextFields.matching(identifier: "Password").element(boundBy: 0)
        emailfield.tap()
        emailfield.typeText("ui.privacy.utsa1@gmail.com")
        password.tap()
        password.typeText("utsa123456")
        tablesQuery.buttons["Sign In"].tap()
        sleep(4)
        
    }
    
    func welcome() {

        app.staticTexts["Welcome to Simplenote"].tap()
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)
        app.swipeLeft()
        sleep(1)
        app.buttons["Get Started"].tap()
        
    }
    
    func signUp() {
        
        let tablesQuery = app.tables
        
        let emailfield = tablesQuery.textFields.matching(identifier: "email@email.com").element(boundBy: 0)
        emailfield.tap()
        emailfield.typeText(username)
        
        let password = tablesQuery.secureTextFields.matching(identifier: "Password").element(boundBy: 0)
        password.tap()
        password.typeText("utsa123456")
        
        let passwordconfirm = tablesQuery.secureTextFields.matching(identifier: "Confirm").element(boundBy: 0)
        passwordconfirm.tap()
        passwordconfirm.typeText("utsa123456")
        
        tablesQuery.buttons["Sign Up"].tap()

    }
    
    func signInWithError() {
        
        let tablesQuery = app.tables
        tablesQuery.buttons["SIGN IN »"].tap()
        let emailfield = tablesQuery.textFields.matching(identifier: "email@email.com").element(boundBy: 0)
        let password = tablesQuery.secureTextFields.matching(identifier: "Password").element(boundBy: 0)
        
        // sign in with wrong email
        tablesQuery.buttons["Sign In"].tap()
        
        // sign in with wrong password
        emailfield.tap()
        emailfield.typeText("ui.privacy.utsa1@gmail.com")
        tablesQuery.buttons["Sign In"].tap()
        
        // sign in
        password.tap()
        password.typeText("utsa123456")
        tablesQuery.buttons["Sign In"].tap()

    }
    
    func printTimeNow() -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let index = timestamp.index(timestamp.startIndex, offsetBy: 8)
        let timenow = "Today, ".appending(timestamp.substring(from: index))
        return timenow
    }

    
    func testSettingsPreferences() {
        
        
        let sidebarElement = app.navigationBars["SPNoteListView"].otherElements["Sidebar"]
        sidebarElement.tap()
        app.buttons["Settings"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.switches["Sort Notes Alphabetically"].tap()
        tablesQuery.switches["Condensed Note List"].tap()
        tablesQuery.switches["Dark Theme"].tap()
        app.navigationBars["Settings"].buttons["Done"].tap()
        sidebarElement.tap()
        
    }
    
    func testSettingsSecurity() {
        
        
        let sidebarElement = app.navigationBars["SPNoteListView"].otherElements["Sidebar"]
        sidebarElement.tap()
        app.buttons["Settings"].tap()
        let passcodeStaticText = app.tables.staticTexts["Passcode"]
        passcodeStaticText.tap()
        
        // set password
        if app.navigationBars["Set Passcode"].staticTexts["Set Passcode"].exists {
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
            sleep(2)
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
        }
        
        passcodeStaticText.tap()
        // trun off password
        if app.navigationBars["Turn off Passcode"].staticTexts["Turn off Passcode"].exists {
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
            app.keys["0"].tap()
        }
        
        app.navigationBars["Settings"].buttons["Done"].tap()
        sidebarElement.tap()
        
    }
    
    func testNewNote() {
        
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["A"].tap()
        app.keys["p"].tap()
        app.keys["p"].tap()
        app.keys["l"].tap()
        app.keys["e"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("red")
        
        app.navigationBars["SPNoteEditorView"].buttons["Menu"].tap()
        app.buttons["Pin toggle"].tap()
        app.buttons["Markdown toggle"].tap()
        app.buttons["Publish toggle"].tap()
        app.buttons["Done"].tap()
        app.navigationBars["SPNoteEditorView"].buttons["Notes"].tap()
        sleep(3)
        
        app.tables.cells.staticTexts.matching(identifier: "Apple").element(boundBy: 0).tap()
        let spnoteeditorviewNavigationBar = app.navigationBars["SPNoteEditorView"]
        spnoteeditorviewNavigationBar.buttons["Menu"].tap()
        app.buttons["Markdown toggle"].tap()
        app.buttons["Pin toggle"].tap()
        app.buttons["Done"].tap()
        spnoteeditorviewNavigationBar.buttons["Notes"].tap()
        
 
    }
    
    /*
    func testAddNoteCollaborate() {
        
        login()
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["B"].tap()
        app.keys["a"].tap()
        app.keys["n"].tap()
        app.keys["a"].tap()
        app.keys["n"].tap()
        app.keys["a"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("yellow")
        
        app.navigationBars["SPNoteEditorView"].buttons["Menu"].tap()
        app.buttons["Collaborate"].tap()
        sleep(3)
        if app.alerts["“Simplenote” Would Like to Access Your Contacts"].exists {
            app.alerts["“Simplenote” Would Like to Access Your Contacts"].buttons["OK"].tap()
        }

        app.textFields["Add a new collaborator..."].buttons["button new small"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Kate Bell"].tap()
        tablesQuery.cells.containing(.staticText, identifier:"kate-bell@mac.com").staticTexts["work"].tap()
        app.navigationBars["Collaborators"].buttons["Done"].tap()
        app.navigationBars["SPNoteEditorView"].buttons["Notes"].tap()
        logout()
        
    }
    
    
    func testAddNoteShare() {
        
        //login()
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["P"].tap()
        app.keys["e"].tap()
        app.keys["a"].tap()
        app.keys["c"].tap()
        app.keys["h"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("pink")
        
        app.navigationBars["SPNoteEditorView"].buttons["Menu"].tap()
        
        let menuButton = app.navigationBars["SPNoteEditorView"].buttons["Menu"]
        menuButton.tap()
        let shareNoteButton = app.buttons["Send"]
        shareNoteButton.tap()
        // copy
        let collectionViewsQuery = app.collectionViews.collectionViews
        collectionViewsQuery.buttons["Copy"].tap()
        // print
        menuButton.tap()
        shareNoteButton.tap()
        collectionViewsQuery.buttons["Print"].tap()
        app.navigationBars["Printer Options"].buttons["Cancel"].tap()
        // add to drive
        menuButton.tap()
        shareNoteButton.tap()
        collectionViewsQuery.buttons["Add To iCloud Drive"].tap()
        app.navigationBars["iCloud Drive"].buttons["Cancel"].tap()
        app.navigationBars["SPNoteEditorView"].buttons["Notes"].tap()
        logout()
        
    }*/
    
    func testAddNoteTrash() {
     
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["P"].tap()
        app.keys["e"].tap()
        app.keys["a"].tap()
        app.keys["r"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("yellow")

        app.navigationBars["SPNoteEditorView"].buttons["Menu"].tap()
        app.buttons["Trash"].tap()
        
        let spnotelistviewNavigationBar = app.navigationBars["SPNoteListView"]
        spnotelistviewNavigationBar.otherElements["Sidebar"].tap()
        app.tables.buttons["Trash"].tap()
        spnotelistviewNavigationBar.buttons["Empty trash"].tap()
        app.alerts.buttons["Yes"].tap()

    }
    
    func testEditTags() {
  
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["L"].tap()
        app.keys["i"].tap()
        app.keys["m"].tap()
        app.keys["e"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("green")
        app.navigationBars["SPNoteEditorView"].buttons["Notes"].tap()
        
        let sidebarElement = app.navigationBars["SPNoteListView"].otherElements["Sidebar"]
        sidebarElement.tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["fruit"].tap()
        sidebarElement.tap()
        tablesQuery.staticTexts["green"].tap()
        sidebarElement.tap()
        tablesQuery.buttons["Edit"].tap()
        tablesQuery.buttons["Done"].tap()
        app.navigationBars["SPNoteListView"].otherElements["Sidebar"].tap()

    }
    
    func testAddNoteHistory() {
        app.navigationBars["SPNoteListView"].buttons["New note"].tap()
        app.keys["P"].tap()
        app.keys["e"].tap()
        app.keys["a"].tap()
        app.keys["c"].tap()
        app.keys["h"].tap()
        app.keys["space"].tap()
        
        sleep(10)
        
        app.keys["p"].tap()
        app.keys["e"].tap()
        app.keys["a"].tap()
        app.keys["c"].tap()
        app.keys["h"].tap()
        
        let tagfield = app.textViews.textFields["Tag..."]
        tagfield.tap()
        tagfield.typeText("fruit")
        
        app.buttons["Next"].tap()
        tagfield.tap()
        tagfield.typeText("frank")
        app.buttons["Next"].tap()
        
        let frankButton = app.textViews.buttons["frank"]
        frankButton.tap()
        frankButton.tap()

        let menuButton = app.navigationBars["SPNoteEditorView"].buttons["Menu"]
        menuButton.tap()
        
        let historyButton = app.buttons["History"]
        historyButton.tap()
        app.buttons["Restore Note"].tap()

    }
  
}
