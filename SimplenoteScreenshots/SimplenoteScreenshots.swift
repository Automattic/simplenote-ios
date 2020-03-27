import XCTest

class SimplenoteScreenshots: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
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

        let firstNote = app.cells["Welcome to Simplenote!"]
        XCTAssertTrue(firstNote.waitForExistence(timeout: 10))
        firstNote.tap()

        let backButton = app.buttons.matching(NSPredicate(format: "label = %@", "Notes")).firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))

        snapshot("0MarkdownPreview")
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
