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

    class func enterEmailAndAttemptLogin(email: String) {
        enterEmail(enteredValue: email)
        app.buttons[UID.Button.logInWithEmail].tap()
     }

    class func enterEmail(enteredValue: String) {
        let field = app.textFields[UID.TextField.email]
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

}
