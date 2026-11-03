import XCTest
@testable import Simplenote

// MARK: - UITextView Auto Bullets Tests
//
class UITextViewAutoBulletsTests: XCTestCase {

    /// Verifies that Return on an empty bullet continues the list instead of removing the marker
    ///
    func testReturnOnEmptyBulletContinuesTheList() {
        let textView = UITextView()
        textView.text = "- "
        textView.selectedRange = NSRange(location: 2, length: 0)

        let handled = textView.applyAutoBullets(withReplacementText: "\n", replacementRange: textView.selectedRange)

        XCTAssertTrue(handled)
        XCTAssertEqual(textView.text, "- \n- ")
        XCTAssertEqual(textView.selectedRange, NSRange(location: 5, length: 0))
    }
}
