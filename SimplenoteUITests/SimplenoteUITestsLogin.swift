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
		EmailLogin.open()
		EmailLogin.logIn(email: "", password: "")

		Assert.labelExists(labelText: Text.loginEmailInvalid)
		Assert.labelExists(labelText: Text.loginPasswordShort)
	}

	func testLogInWithNoEmail() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: "", password: testDataExistingPassword)

		Assert.labelExists(labelText: Text.loginEmailInvalid)
		Assert.labelAbsent(labelText: Text.loginPasswordShort)
	}

	func testLogInWithInvalidEmail() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: testDataInvalidEmail, password: testDataExistingPassword)

		Assert.labelExists(labelText: Text.loginEmailInvalid)
		Assert.labelAbsent(labelText: Text.loginPasswordShort)
	}

	func testLogInWithNoPassword() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: testDataExistingEmail, password: "")

		Assert.labelAbsent(labelText: Text.loginEmailInvalid)
		Assert.labelExists(labelText: Text.loginPasswordShort)
	}

	func testLogInWithTooShortPassword() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: testDataExistingEmail, password: testDataInvalidPassword)

		Assert.labelAbsent(labelText: Text.loginEmailInvalid)
		Assert.labelExists(labelText: Text.loginPasswordShort)
	}

	func testLogInWithExistingEmailIncorrectPassword() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: testDataExistingEmail, password: testDataNotExistingPassword)
		Assert.alertExistsAndClose(headingText: Text.alertHeadingSorry, content: Text.alertContentLoginFailed, buttonText: UID.Button.accept)
	}

	func testLogInWithCorrectCredentials() throws {
		EmailLogin.open()
		EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
		AllNotesAssert.screenShown()
	}

	func testLogOut() throws {
		// Step 1
		EmailLogin.open()
		EmailLogin.logIn(email: testDataExistingEmail, password: testDataExistingPassword)
		AllNotesAssert.screenShown()

		// Step 2
		_ = logOut()
		Assert.signUpLogInScreenShown()
	}
}
