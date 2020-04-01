import XCTest

class SimplenoteScreenshots: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
        UIPasteboard.general.strings = []
    }

    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let login = app.buttons["Log In"]

        if login.waitForExistence(timeout: 3) == false {
            logout(using: app)
        }
        XCTAssertTrue(login.waitForExistence(timeout: 10))
        login.tap()

        let loginViaEmail = app.buttons["Log in with email"]
        XCTAssertTrue(loginViaEmail.waitForExistence(timeout: 10))
        loginViaEmail.tap()

        let email = app.textFields["Email"]
        XCTAssertTrue(email.waitForExistence(timeout: 10))
        email.typeText(ScreenshotsCredentials.testUserEmail)

        let password = app.secureTextFields["Password"]
        XCTAssertTrue(password.waitForExistence(timeout: 10))
        // -.-'
        password.tap()
        password.pasteText(text: ScreenshotsCredentials.testUserPassword)

        // Need to check for the login button again, otherwise we'll attempt to press the one from
        // the previous screen.
        let newLogin = app.buttons["Log In"]
        XCTAssertTrue(newLogin.waitForExistence(timeout: 10))
        newLogin.tap()

        let firstNote = app.cells["Mac ‘n’ Cheese with Bacon Recipe"]
        XCTAssertTrue(firstNote.waitForExistence(timeout: 10))

        firstNote.tap()

        let actionButton = app.buttons.matching(identifier: "note-menu").firstMatch
        XCTAssertTrue(actionButton.waitForExistence(timeout: 10))

        snapshot("1-note")

        actionButton.tap()

        let collaborateButton = app.buttons["Collaborate"]
        XCTAssertTrue(collaborateButton.waitForExistence(timeout: 3))

        collaborateButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3))

        // The index 3 is _intentional_ as that's the desired position of the screenshot in the App
        // Store
        snapshot("3-collaborators")

        // Tapping done in the collaborate view dismisses the collaborate screen _and_ the action
        // menu.
        doneButton.tap()

        let backButton = app.buttons.matching(NSPredicate(format: "label = %@", "Notes")).firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()

        // Before taking a screenshot of the notes, make sure the review prompt header is not on
        // screen.
        let reviewPromptButton = app.buttons["I like it"]
        if reviewPromptButton.waitForExistence(timeout: 3) {
            reviewPromptButton.tap()

            let dismissReviewButton = app.buttons["No thanks"]
            XCTAssertTrue(dismissReviewButton.waitForExistence(timeout: 3))
            dismissReviewButton.tap()

            // also wait for dismiss animation, just in case
            XCTAssertFalse(dismissReviewButton.waitForExistence(timeout: 3))
        }

        snapshot("2-all-notes")

        openMenu(using: app)

        let allNotesMenuInput = app.cells.matching(identifier: "all-notes").firstMatch
        XCTAssertTrue(allNotesMenuInput.waitForExistence(timeout: 3))

        snapshot("4-menu")

        allNotesMenuInput.tap()

        let searchBar = app.otherElements["search-bar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 3))
        searchBar.tap()

        searchBar.typeText("Recipe")

        let searchCancelButton = app.buttons["Cancel"]
        XCTAssertTrue(searchCancelButton.waitForExistence(timeout: 3))

        // Dismiss the keyboard before taking the screenshot
        app.swipeUp()
        app.swipeDown()

        snapshot("5-search")

        searchCancelButton.tap()

        openMenu(using: app)
        loadPasscodeScreen(using: app)
        // Set the passcode
        // Writing the value here in clear because anyways one can see it being typed.
        type("1234", onFirstKeyboardOf: app)
        // Confirm it
        type("1234", onFirstKeyboardOf: app)

        // Kill the app and relaunch it so we can take a screenshot of the lock screen
        app.terminate()
        app.launch()

        // Assuming that if a keyboard is on screen, then the passcode screen has loaded
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 10))

        // The screenshot for the passcode should have only 3 characters inserted
        type("123", onFirstKeyboardOf: app)

        snapshot("6-passcode")

        type("4", onFirstKeyboardOf: app)

        // Now, disable the passcode so we're not blocked by it on next launch.
        openMenu(using: app)
        loadPasscodeScreen(using: app)
        type(ScreenshotsCredentials.testUserPasscode, onFirstKeyboardOf: app)
    }

    func logout(using app: XCUIApplication) {
        let menu = app.otherElements.matching(identifier: "menu").firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 10))

        menu.tap()

        let settings = app.textFields["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()

        let logOut = app.staticTexts["Log Out"]
        XCTAssertTrue(logOut.waitForExistence(timeout: 3))
        logOut.tap()
    }

    func openMenu(using app: XCUIApplication) {
        let menu = app.otherElements.matching(identifier: "menu").firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 10))
        menu.tap()
    }

    func loadPasscodeScreen(using app: XCUIApplication) {
        let settingsMenuInput = app.cells["settings"]
        XCTAssertTrue(settingsMenuInput.waitForExistence(timeout: 3))
        settingsMenuInput.tap()

        let passcodeCell = app.cells["passcode-cell"]
        XCTAssertTrue(passcodeCell.waitForExistence(timeout: 3))
        passcodeCell.tap()

        // Let's just assume that if a keyboard is on screen, then the passcode screen has loaded
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 3))
    }

    func type(_ text: String, onFirstKeyboardOf app: XCUIApplication) {
        text.forEach { app.keyboards.firstMatch.keys[String($0)].tap() }
    }
}

extension XCUIElement {

    func pasteText(text: String) -> Void {
        let previousPasteboardContents = UIPasteboard.general.string
        UIPasteboard.general.string = text

        self.press(forDuration: 1.2)
        XCUIApplication().menuItems.firstMatch.tap()

        if let string = previousPasteboardContents {
            UIPasteboard.general.string = string
        }
    }
}
