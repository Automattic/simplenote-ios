import XCTest
@testable import Simplenote


// MARK: - CGRect Tests
//
class CGRectSimplenoteTests: XCTestCase {

    /// Verifies that `splity(by:)` returns zero CGRect.zero in the upper slice and self in the lower slice whenever the anchor is invalid
    ///
    func testSplitByRectReturnsTheReceiversRectWheneverTheInputIsInvalid() {
        let input = CGRect(x: .zero, y: .zero, width: 300, height: 300)
        let anchor = CGRect(x: -1, y: -1, width: .zero, height: .zero)

        let (upper, lower) = input.split(by: anchor)

        XCTAssertEqual(upper, .zero)
        XCTAssertEqual(lower, input)
    }

    /// Verifies that `splity(by:)` returns a zero height lower slice whenever the anchor has Zero location and Height
    ///
    func testSplitByRectReturnsEmptyLowerSliceWheneverTheInputHasZeroHeight() {
        let input = CGRect(x: .zero, y: .zero, width: 300, height: 300)
        let anchor = CGRect(x: .zero, y: .zero, width: 0, height: 0)

        let expectedLower = CGRect(x: .zero, y: .zero, width: 300, height: 0)
        let (upper, lower) = input.split(by: anchor)

        XCTAssertEqual(upper, input)
        XCTAssertEqual(lower, expectedLower)
    }

    /// Verifies that `splity(by:)` returns the expected Slices
    ///
    func testSplitByRectReturnsTheExpectedResultingSlices() {
        let input = CGRect(x: .zero, y: .zero, width: 300, height: 300)
        let anchor = CGRect(x: .zero, y: 100, width: .zero, height: 100)

        let expectedUpper = CGRect(x: .zero, y: 200, width: 300, height: 100)
        let expectedLower = CGRect(x: .zero, y: .zero, width: 300, height: 100)
        let (upper, lower) = input.split(by: anchor)

        XCTAssertEqual(upper, expectedUpper)
        XCTAssertEqual(lower, expectedLower)
    }
}
