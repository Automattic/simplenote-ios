import ScreenObject
import XCTest

public class PasscodeScreen: ScreenObject {

    public init(app: XCUIApplication = XCUIApplication()) throws {
        try super.init(
            expectedElementGetters: [ { $0.staticTexts["1"].firstMatch }, { $0.staticTexts["4"].firstMatch }, { $0.staticTexts["7"].firstMatch }, { $0.staticTexts["0"].firstMatch }
            ],
            app: app
        )
    }

    public func type(passcode: Int) {
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

    public static func isLoaded(in app: XCUIApplication = XCUIApplication()) -> Bool {
        do {
            let screen = try PasscodeScreen(app: app)
            return screen.isLoaded
        } catch {
            return false
        }
    }
}
