import UITestHelpers
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

        // The tests have been known to fail in the passcode screen inconsistently.
        //
        // This becomes a problem when running the screenshots automation through Fastlane because
        // it retries three times. A failure in the passcode screen results in the PIN screen not
        // being disabled, which in turn would result in the passcode screen being presented at
        // launch, preventing the test from proceeding.
        dismissPasscodeScreenIfNeeded(using: app)

        dismissVerifyEmailIfNeeded(using: app)

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
        password.typeSecureText(ScreenshotsCredentials.testUserPassword, using: app)

        // Need to check for the login button again, otherwise we'll attempt to press the one from
        // the previous screen.
        let newLogin = app.buttons["Log In"]
        XCTAssertTrue(newLogin.waitForExistence(timeout: 10))
        newLogin.tap()

        dismissVerifyEmailIfNeeded(using: app)

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

        // We need to add text at the end of the note. There is no dedicated API to do so. Our best
        // bet is to try to scroll the text view to the bottom and tap there. There are no APIs for
        // that either, so our next best bet is to 1) swipe up real fast to simulate a scroll to the
        // bottom; 2) tap in the bottom right corner of the text view.
        //
        // Fun (?) fact worth tracking here for future reference. On the iPad Simulator^, tapping on
        // the `noteTextView` `XCUIElement` doesn't work. Luckily, tapping on the `XCUICoordinate`
        // works. Another option could have been to call `tap()` on the `XCUIApplication` itself,
        // but that might result in tapping in the middle of the text on a small screen.
        //
        // ^: iPad Pro 12.9" 2nd and 3rd generation Simulator on Xcode 12.3.
        noteTextView.swipeUp(velocity: .fast)
        let lowerRightCorner = noteTextView.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        lowerRightCorner.tap()

        let interlinkingTriggerString = "\n[L"
        noteTextView.typeText(interlinkingTriggerString)

        // Before taking the screenshot, let's make sure the inter note liking window appeared by
        // checking the text of one of its notes is on screen
        XCTAssertTrue(app.staticTexts["Blueberry Recipes"].firstMatch.waitForExistence(timeout: 1))

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
        // Writing the value here in clear because one can see it being typed anyways.
        typeOnPassCodeScreen(1234, using: app)
        // Confirm it
        typeOnPassCodeScreen(1234, using: app)

        // Kill the app and relaunch it so we can take a screenshot of the lock screen
        app.terminate()
        app.launch()

        // The screenshot for the passcode should have only 3 characters inserted.
        // (Typing in the passcode screen also ensures it's visible first)
        typeOnPassCodeScreen(123, using: app)

        takeScreenshot("6-passcode")

        typeOnPassCodeScreen(4, using: app)

        dismissVerifyEmailIfNeeded(using: app)

        // Now, disable the passcode so we're not blocked by it on next launch.
        openMenu(using: app)
        loadPasscodeScreen(using: app)
        typeOnPassCodeScreen(1234, using: app)
    }

    func dismissVerifyEmailIfNeeded(using app: XCUIApplication) {
        guard app.staticTexts["Verify Your Email"].waitForExistence(timeout: 10) else { return }
        app.buttons["icon cross"].tap()
    }

    func logout(using app: XCUIApplication) {
        getMenuButtonElement(from: app).tap()

        let settings = app.staticTexts["Settings"]
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

        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in self.isPasscodeScreenVisible(using: app) },
            object: .none
        )
        wait(for: [expectation], timeout: 5)
    }

    func dismissPasscodeScreenIfNeeded(using app: XCUIApplication) {
        guard isPasscodeScreenVisible(using: app) else { return }
        typeOnPassCodeScreen(1234, using: app)
    }

    func isPasscodeScreenVisible(using app: XCUIApplication) -> Bool {
        // Check there's a button for each line of the custom number keypad.
        //
        // We only need to wait for the first number, if that's on screen, then the others should be
        // on screen already, too.
        return app.staticTexts["1"].waitForExistence(timeout: 3)
            && app.staticTexts["4"].exists
            && app.staticTexts["7"].exists
            && app.staticTexts["0"].exists
    }

    func typeOnPassCodeScreen(_ input: Int, using app: XCUIApplication) {
        // This converts an Int into an [Int] of its digits
        let digits = "\(input.magnitude)".compactMap(\.wholeNumberValue)

        digits.forEach { digit in
            let input = app.staticTexts["\(digit)"]
            XCTAssertTrue(input.waitForExistence(timeout: 3))
            // Both the custom UIButton and its UILabel match the "\(digit)" query. We need to pick
            // one for the tap to work.
            input.firstMatch.tap()
        }
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

extension XCUIElement {

    /// Workaround to type text into secure text fields due to the different behaviors across
    /// Simulators.
    func typeSecureText(_ text: String, using app: XCUIApplication) -> Void {
        tap()

        // At the time of writing, typing in a secure text field didn't work in some of the
        // Simulators on which we want to take screenshots. On top of that, the workaround to type
        // in the secure text field doesn't work in some other Simulators. Therefore, we need to
        // know which approach to use at runtime.
        if requiresSecureTextFieldWorkaround(using: app) {
            paste(text: text)
        } else {
            typeText(text)
        }
    }

    private func requiresSecureTextFieldWorkaround(using app: XCUIApplication) -> Bool {
        // At the time of writing, these tests run on the following iOS 14.3 Simulators as defined
        // in the Fastfile.
        //
        // - iPhone 8 Plus
        // - iPhone Xs
        // - iPad Pro 12.9" 2nd generation
        // - iPad Pro 12.9" 3rd generation
        //
        // Of those, the only one requiring the secure text field workaround is the iPhone 8 Plus
        // one.
        return app.isDeviceIPhone8Plus()
    }
}
