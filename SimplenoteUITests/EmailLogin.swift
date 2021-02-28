import XCTest

class EmailLogin {

    class func open() {
        app.buttons[UID.Button.logIn].tap()
        app.buttons[UID.Button.logInWithEmail].tap()
    }

    class func close() {
        let backButton = app.navigationBars[UID.NavBar.logIn].buttons[UID.Button.back]
        guard backButton.isHittable else { return }

        backButton.tap()
    }

    class func logIn(email: String, password: String) {
        enterEmail(enteredValue: email)
        enterPassword(enteredValue: password)
        app.buttons[UID.Button.logIn].tap()
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
}
