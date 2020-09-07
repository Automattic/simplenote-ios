import XCTest
@testable import Simplenote


// MARK: - NSString Simplenote Tests
//
class StringSimplenoteTests: XCTestCase {

    /// Verifies that `truncateWords(upTo:) ` returns the N first characters of the receiver, whenever there are no words in the specified range.
    ///
    func testTruncateWordsReturnsTruncatedStringWheneverThereAreNoWords() {
        let sample = "1234567890"
        let expected = "12345"

        XCTAssertEqual(sample.truncateWords(upTo: 5), expected)
    }

    /// Verifies that `truncateWords(upTo:) ` truncates the receiver's full words, up to a maximum length.
    ///
    func testTruncateWordsReturnsWordsInSpecifiedRangeUpToMaximumLength() {
        let sample = "uno dos tres catorce!"
        let expected = "uno dos"

        XCTAssertEqual(sample.truncateWords(upTo: 10), expected)
    }
}
