import XCTest
@testable import Simplenote

// MARK: - CGRect Tests
//
class CGRectSimplenoteTests: XCTestCase {

    /// Verifies that `splity(by:)` returns a zero height lower slice whenever the anchor has Zero location and Height
    ///
    func testSplitByRectReturnsEmptyLowerSliceWheneverTheInputHasZeroHeight() {
        let input = CGRect(x: .zero, y: .zero, width: 300, height: 300)
        let anchor = CGRect(x: .zero, y: .zero, width: 0, height: 0)

        let expectedBelow = CGRect(x: .zero, y: .zero, width: 300, height: 0)
        let (above, below) = input.split(by: anchor)

        XCTAssertEqual(above, input)
        XCTAssertEqual(below, expectedBelow)
    }

    /// Verifies that `splity(by:)` returns the expected Slices
    ///
    func testSplitByRectReturnsTheExpectedResultingSlices() {
        let input = CGRect(x: .zero, y: .zero, width: 300, height: 300)
        let anchor = CGRect(x: .zero, y: 100, width: .zero, height: 100)

        let expectedAbove = CGRect(x: .zero, y: 200, width: 300, height: 100)
        let expectedBelow = CGRect(x: .zero, y: .zero, width: 300, height: 100)
        let (above, below) = input.split(by: anchor)

        XCTAssertEqual(above, expectedAbove)
        XCTAssertEqual(below, expectedBelow)
    }
}
