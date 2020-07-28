import XCTest
@testable import Simplenote


// MARK: - NSString Simplenote Tests
//
class NSStringSimplenoteTests: XCTestCase {

    /// Verifies that `substringUpToFirstSpace` returns the unmodified string, whenever there are no actual spaces.
    ///
    func testSubstringUpToFirstSpaceReturnsTheUnmodifiedStringWhenThereAreNoSpaces() {
        let sample = "1234567890!@#$%^&*()-_+[]';./,qwertyuiop"
        XCTAssertEqual(sample.substringUpToFirstSpace, sample)
    }

    /// Verifies that `substringUpToFirstSpace` returns the actual substring "before" the first space
    ///
    func testSubstringUpToFirstSpaceReturnsTheSubstringContainedBeforeTheFirstSace() {
        let textBeforeSpace = "1234567890!@#$%^&*()-_+[]';./,qwertyuiop"
        let sample = textBeforeSpace + .space + "1234" + .space + "67890"
        XCTAssertEqual(sample.substringUpToFirstSpace, textBeforeSpace)
    }
}
