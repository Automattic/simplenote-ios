import XCTest

class SimplenoteUISmokeTestsLogin: XCTestCase {
    let testDataInvalidEmail = "user@gmail."
    let testDataNotExistingEmail = "nevergonnagiveyouup@gmail.com"
    let testDataInvalidPassword = "ABC"
    let testDataNotExistingPassword = "ABCD"

    override class func setUp() {
        app.launch()
    }

    override func setUpWithError() throws {
        Alert.closeAny()
        EmailLogin.close()
        let _ = attemptLogOut()
    }

    func testLogInWithNoEmailNoPassword() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: "")
        Assert.labelExists(labelText: Text.loginEmailInvalid)
        Assert.labelExists(labelText: Text.loginPasswordShort)
    }

    func testLogInWithNoEmail() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: "", password: testDataExistingPassword)
        Assert.labelExists(labelText: Text.loginEmailInvalid)
        Assert.labelAbsent(labelText: Text.loginPasswordShort)
    }

    func testLogInWithInvalidEmail() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataInvalidEmail, password: testDataExistingPassword)
        Assert.labelExists(labelText: Text.loginEmailInvalid)
        Assert.labelAbsent(labelText: Text.loginPasswordShort)
    }

    func testLogInWithNoPassword() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: "")
        Assert.labelAbsent(labelText: Text.loginEmailInvalid)
        Assert.labelExists(labelText: Text.loginPasswordShort)
    }

    func testLogInWithTooShortPassword() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataInvalidPassword)
        Assert.labelAbsent(labelText: Text.loginEmailInvalid)
        Assert.labelExists(labelText: Text.loginPasswordShort)
    }

    func testLogInWithExistingEmailIncorrectPassword() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataNotExistingPassword)
        Assert.alertExistsAndClose(headingText: Text.alertHeadingSorry, content: Text.alertContentLoginFailed, buttonText: UID.Button.accept)
    }

    func testLogInWithCorrectCredentials() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        NoteListAssert.allNotesShown()
    }

    func testLogOut() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
        NoteListAssert.allNotesShown()

        trackStep()
        _ = logOut()
        Assert.signUpLogInScreenShown()
    }
}
