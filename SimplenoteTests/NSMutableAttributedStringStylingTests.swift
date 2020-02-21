import XCTest
@testable import Simplenote


// MARK: - NSMutableAttributedString Styling Tests
//
class NSMutableAttributedStringStylingTests: XCTestCase {

    ///
    ///
    func testChecklistShouldNotRenderWithinText() {
        let inlineChecklist = "This is a badly formed todo - [ ] Buy avocados"
        let regex = try! NSRegularExpression(pattern: NSAttributedStringRegexForChecklists, options: .anchorsMatchLines)
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertTrue(matches.isEmpty)
    }

    ///
    ///
    func testChecklistRenderWithPrefixedWhitespace() {
        let inlineChecklist = "       - [ ] Buy avocados - [ ] "
        let regex = try! NSRegularExpression(pattern: NSAttributedStringRegexForChecklists, options: .anchorsMatchLines)
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))

        XCTAssertEqual(matches.count, 1)
    }

    ///
    ///
    func testMatchProperlyFormattedChecklistSyntax() {
        let inlineChecklist = "ToDo\n\n- [ ] Buy avocados\n- [ ] Ship it\n- [x ] Malformed!\n- [x] Correct."
        let regex = try! NSRegularExpression(pattern: NSAttributedStringRegexForChecklists, options: .anchorsMatchLines)
        let matches = regex.matches(in: inlineChecklist, options: [], range: NSMakeRange(0, inlineChecklist.count))
        
        XCTAssertEqual(matches.count, 3)
    }
}
