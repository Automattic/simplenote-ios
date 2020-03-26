import XCTest

class SimplenoteScreenshots: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testScreenshots() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Sign Up"].exists)
        XCTAssertTrue(app.staticTexts["Log In"].exists)
    }
}
