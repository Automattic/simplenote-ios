import XCTest

class EmailLogin {

    class func open() {
        app.buttons[UID.Button.logIn].waitForIsHittable()
        app.buttons[UID.Button.logIn].tap()
    }

    class func close() {
        /// Exit: We're already in the Onboarding UI
        ///
        if app.buttons[UID.Button.logIn].exists, app.buttons[UID.Button.signUp].exists {
            return
        }
        
        /// Back from Password > Code UI
        ///
        let backFromPasswordUI = app.navigationBars[UID.NavBar.logInWithPassword].buttons.element(boundBy: 0)
        if backFromPasswordUI.exists {
            backFromPasswordUI.tap()
            _ = app.navigationBars[UID.NavBar.enterCode].waitForExistence(timeout: minLoadTimeout)
        }
        
        /// Back from Code UI > Email UI
        /// Important: When rate-limited, the Code UI is skipped
        ///
        let codeNavigationBar = app.navigationBars[UID.NavBar.enterCode]
        if codeNavigationBar.exists {
            codeNavigationBar.buttons.element(boundBy: 0).tap()
            _ = app.navigationBars[UID.NavBar.logIn].waitForExistence(timeout: minLoadTimeout)
        }

        /// Back from Email UI > Onboarding
        ///
        let emailNavigationBar = app.navigationBars[UID.NavBar.logIn]
        if emailNavigationBar.exists {
            emailNavigationBar.buttons.element(boundBy: 0).tap()
        }

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
        app.buttons[UID.Button.logInWithEmail].tap()
        
        /// Code UI > Password UI
        /// Important: When rate-limited, the Code UI is skipped
        ///
        let codeNavigationBar = app.navigationBars[UID.NavBar.enterCode]
        _ = codeNavigationBar.waitForExistence(timeout: minLoadTimeout)
        
        if codeNavigationBar.exists {
            app.buttons[UID.Button.enterPassword].tap()
        }
        
        /// Password UI
        ///
        _ = app.buttons[UID.Button.logIn].waitForExistence(timeout: minLoadTimeout)
        enterPassword(enteredValue: password)
        app.buttons[UID.Button.mainAction].tap()
        handleSavePasswordPrompt()
        waitForSpinnerToDisappear()
    }
    
    class func enterEmailAndAttemptLogin(email: String) {
        enterEmail(enteredValue: email)
        app.buttons[UID.Button.logInWithEmail].tap()
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
