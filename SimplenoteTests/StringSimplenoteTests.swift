import XCTest
@testable import Simplenote


// MARK: - String Simplenote Unit Tests
//
class StringSimplenoteTests: XCTestCase {

    /// Verifies that Suffix after Prefix returns nil, whenever such prefix isn't to be found
    ///
    func testSuffixAfterPrefixReturnsNilWheneverTheInputStringLacksSuchPrefix() {
        let sample = "This is a sample of some random string without the tag operator"
        XCTAssertNil(sample.suffix(afterPrefix: .searchOperatorForTags))
    }

    /// Verifies that Suffix after Prefix returns an empty string, whenever there is no actual Payload
    ///
    func testSuffixAfterPrefixReturnsNilWheneverTheTagSearchOperatorHasAnEmptyKeyword() {
        let sample = String.searchOperatorForTags
        XCTAssertNil(sample.suffix(afterPrefix: .searchOperatorForTags))
    }

    /// Verifies that Suffix after Prefix returns the payload right after the first occurrence of such suffix
    ///
    func testSuffixAfterPrefixReturnsTheRightHandSideStringAfterTheTagSearchOperator() {
        let expected = "somenameforatag"
        let sample = String.searchOperatorForTags + expected

        XCTAssertEqual(sample.suffix(afterPrefix: .searchOperatorForTags), expected)
    }
}
