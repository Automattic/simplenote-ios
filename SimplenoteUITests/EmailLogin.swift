import XCTest

class EmailLogin {

    class func open() {
        app.buttons[UID.Button.LogIn].tap()
        app.buttons[UID.Button.LogInWithEmail].tap()
    }

    class func close() {
        let backButton = app.navigationBars[UID.NavBar.LogIn].buttons[UID.Button.Back]
        guard backButton.exists else { return }

        backButton.tap()
    }

    class func logIn(email: String, password: String) {
        enterEmail(enteredValue: email)
        enterPassword(enteredValue: password)
        app.buttons[UID.Button.LogIn].tap()
    }

    class func enterEmail(enteredValue: String) {
        let field = app.textFields[UID.TextField.Email]
        field.tap()
        field.typeText(enteredValue)
    }

    class func enterPassword(enteredValue: String) {
        let field = app.secureTextFields[UID.TextField.Password]
        field.tap()
        field.typeText(enteredValue)
    }
}
