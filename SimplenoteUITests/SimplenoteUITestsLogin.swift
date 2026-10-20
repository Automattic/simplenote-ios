import UITestsFoundation
import XCTest

class SimplenoteUISmokeTestsLogin: XCTestCase {
    let testDataInvalidEmail = "user@gmail."

    override class func setUp() {
        app.launch()
    }

    override func setUpWithError() throws {
        Alert.closeAny()
        EmailLogin.close()
    }

    func testLogInWithNoEmail() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.enterEmailAndAttemptLogin(email: "")
        Assert.labelExists(labelText: Text.loginEmailInvalid)
    }

    func testLogInWithInvalidEmail() throws {
        trackTest()

        trackStep()
        EmailLogin.open()
        EmailLogin.enterEmailAndAttemptLogin(email: testDataInvalidEmail)
        Assert.labelExists(labelText: Text.loginEmailInvalid)
        Assert.labelAbsent(labelText: Text.loginPasswordShort)
    }
}
