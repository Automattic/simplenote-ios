import ScreenObject
import XCTest

class PasscodeScreen: ScreenObject {

    // TODO: Add more digits verifications once `ScreenObject` support initializing with more than
    // one expected element. The digits we had originally were 1, 4, 7, 0 (one per pad row).
    init(app: XCUIApplication = XCUIApplication()) throws {
        try super.init(
            expectedElementGetter: { $0.staticTexts["1"].firstMatch },
            app: app
        )
    }

    func type(passcode: Int) {
        // This converts an Int into an [Int] of its digits
        let digits = "\(passcode.magnitude)".compactMap(\.wholeNumberValue)

        digits.forEach { digit in
            let input = app.staticTexts["\(digit)"]
            XCTAssertTrue(input.waitForExistence(timeout: 3))
            // Both the custom UIButton and its UILabel match the "\(digit)" query. We need to pick
            // one for the tap to work.
            input.firstMatch.tap()
        }
    }

    static func isLoaded(in app: XCUIApplication = XCUIApplication()) -> Bool {
        do {
            let screen = try PasscodeScreen(app: app)
            return screen.isLoaded
        } catch {
            return false
        }
    }
}
