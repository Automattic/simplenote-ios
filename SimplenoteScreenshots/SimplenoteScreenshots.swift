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
        password.tap()
        password.typeText(ScreenshotsCredentials.testUserPassword)

        // Need to check for the login button again, otherwise we'll attempt to press the one from
        // the previous screen.
        let newLogin = app.buttons["Log In"]
        XCTAssertTrue(newLogin.waitForExistence(timeout: 10))
        newLogin.tap()

        let firstNote = app.cells[noteForDetailScreenshot]
        // Super long timeout in case the test user has many notes and the connection is a bit slow

        XCTAssertTrue(firstNote.waitForExistence(timeout: 20))

        firstNote.tap()

        takeScreenshot("1-note")

        goBackFromEditor(using: app)

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

        takeScreenshot("2-all-notes")

        let interlinkingNote = app.cells[noteForInterlinkingScreenshot]
        XCTAssertTrue(interlinkingNote.waitForExistence(timeout: 5))
        interlinkingNote.tap()

        let noteTextView = app.textViews.firstMatch

        XCTAssertTrue(noteTextView.waitForExistence(timeout: 1))

        // The next step is to type in the note to bring up the inter-note linking view.
        // The natural thing to do here would be tapping the note:
        //
        // noteTextView.tap()
        //
        // Doing so works on iOS, but fails on iPad Pro 12.9" 2nd and 3rd generation, on Xcode 12.3.
        // Luckily, tapping the app itself does the job, too.
        app.tap()

        let interlinkingTriggerString = "\n[L"
        noteTextView.typeText(interlinkingTriggerString)

        takeScreenshot("3-interlinking")

        // Reset for the next test
        (0 ..< interlinkingTriggerString.count).forEach { _ in
            noteTextView.typeText(XCUIKeyboardKey.delete.rawValue)
        }

        goBackFromEditor(using: app)

        openMenu(using: app)

        let allNotesMenuInput = app.cells.matching(identifier: "all-notes").firstMatch
        XCTAssertTrue(allNotesMenuInput.waitForExistence(timeout: 3))

        takeScreenshot("4-menu")

        allNotesMenuInput.tap()

        let searchBar = app.otherElements["search-bar"]
        XCTAssertTrue(searchBar.waitForExistence(timeout: 3))
        searchBar.tap()

        searchBar.typeText("Recipe")

        let searchCancelButton = app.buttons["Cancel"]
        XCTAssertTrue(searchCancelButton.waitForExistence(timeout: 3))

        takeScreenshot("5-search")

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

        takeScreenshot("6-passcode")

        type("4", onFirstKeyboardOf: app)

        // Now, disable the passcode so we're not blocked by it on next launch.
        openMenu(using: app)
        loadPasscodeScreen(using: app)
        type(ScreenshotsCredentials.testUserPasscode, onFirstKeyboardOf: app)
    }

    func logout(using app: XCUIApplication) {
        getMenuButtonElement(from: app).tap()

        let settings = app.textFields["Settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 3))
        settings.tap()

        let logOut = app.staticTexts["Log Out"]
        XCTAssertTrue(logOut.waitForExistence(timeout: 3))
        logOut.tap()
    }

    func goBackFromEditor(using app: XCUIApplication) {
        let backButton = app.buttons.matching(NSPredicate(format: "label = %@", "All Notes")).firstMatch
        XCTAssertTrue(backButton.waitForExistence(timeout: 3))
        backButton.tap()
    }

    func openMenu(using app: XCUIApplication) {
        getMenuButtonElement(from: app).tap()
    }

    func getMenuButtonElement(from app: XCUIApplication) -> XCUIElement {
        let menu = app.buttons.matching(identifier: "menu").firstMatch
        XCTAssertTrue(menu.waitForExistence(timeout: 10))
        return menu
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

    // See https://github.com/woocommerce/woocommerce-ios/blob/mokagio-gems-update-test/WooCommerce/WooCommerceScreenshots/WooCommerceScreenshots.swift#L66-L79
    func takeScreenshot(_ title: String) {
        let mode = isDarkMode ? "dark" : "light"

        snapshot("\(title)-\(mode)")
    }

    let noteForDetailScreenshot = "Lemon Cake & Blueberry"
    let noteForInterlinkingScreenshot = "Colors"
}
