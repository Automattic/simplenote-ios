import XCTest

class EmailLogin {

    class func open() {
        app.buttons[UID.Button.logIn].waitForIsHittable()
        app.buttons[UID.Button.logIn].tap()
        app.buttons[UID.Button.logInWithEmail].waitForIsHittable()
        app.buttons[UID.Button.logInWithEmail].tap()
    }

    class func close() {
        let backButton = app.navigationBars[UID.NavBar.logIn].buttons[UID.Button.back]
        guard backButton.isHittable else { return }

        backButton.tap()
        handleSavePasswordPrompt()
    }

    class func logIn() {
        let testAccountKey = "UI_TEST_ACCOUNT"
        let testAccount: String

        switch ProcessInfo.processInfo.environment[testAccountKey] {
        case .none:
            fatalError("Expected \(testAccountKey) environment variable to be defined in the scheme")
        case .some(let value):
            // Use 'default' account if test account was not passed via environment variable
            testAccount = value.isEmpty ? testDataEmail : value
        }

        EmailLogin.logIn(email: testAccount, password: testDataPassword)
    }

    class func logIn(email: String, password: String) {
        enterEmail(enteredValue: email)
        app.buttons[UID.Button.continueWithPassword].tap()
        _ = app.buttons[UID.Button.logIn].waitForExistence(timeout: minLoadTimeout)
        enterPassword(enteredValue: password)
        app.buttons[UID.Button.logIn].tap()
        handleSavePasswordPrompt()
        waitForSpinnerToDisappear()
    }

    class func enterEmail(enteredValue: String) {
        let field = app.textFields[UID.TextField.email]
        field.tap()
        field.typeText(enteredValue)
    }

    class func enterPassword(enteredValue: String) {
        let field = app.secureTextFields[UID.TextField.password]
        field.tap()
        field.typeText(enteredValue)
    }

    class func handleSavePasswordPrompt() {
        // As of Xcode 14.3, the Simulator might ask to save the password which, of course, we don't want to do.
        if app.buttons["Save Password"].waitForExistence(timeout: 5) {
            // There should be no need to wait for this button to exist since it's part of the same
            // alert where "Save Password" is.
            app.buttons["Not Now"].tap()
        }
    }

    class func waitForSpinnerToDisappear() {
        let predicate   = NSPredicate(format: "exists == false && isHittable == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: app.staticTexts["In progress"])
        XCTWaiter().wait(for: [ expectation ], timeout: 10)
    }
}
