import ScreenObject
import XCTest

class PasscodeScreen: ScreenObject {

    // We need to store this as `static` in order to reuse it between the `static` `isLoaded` and
    // the value in the `init` implementation.
    //
    // We need a `static` `isLoaded` because the current `ScreenObject` version doesn't offer a
    // way to check if a screen is loaded without creating it, but if you create the screen, the
    // framework also verifies it exists via an XCTest assertion. As this use case shows, that's
    // not the most versatile behavior, but we'll address that at a later moment.
    private static let expectedElementGetter: (XCUIApplication) -> XCUIElement = {
        // Note that `firstMatch` is required, otherwise some of the queries internal to
        // `ScreenObject` will fail because there are multiple matches and it just so happen that
        // the one they pick is not the desired one. See the `UIButton` vs `UILabel` comment in
        // the `type(passcode:)` implementation.
        $0.staticTexts["1"].firstMatch
    }

    // TODO: Add more digits verifications once `ScreenObject` support initializing with more than
    // one expected element. The digits we had originally were 1, 4, 7, 0 (one per pad row).
    init(app: XCUIApplication = XCUIApplication()) throws {
        try super.init(expectedElementGetter: Self.expectedElementGetter, app: app)
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
        expectedElementGetter(app).exists
    }
}
