import XCTest
@testable import Simplenote

// MARK: - UIImage+Simplenote Unit Tests
//
class UIImageSimplenoteTests: XCTestCase {

    /// Verify every single UIColorName in existance yields a valid UIColor instancce
    ///
    func testEverySingleUIImageNameEffectivelyYieldsSomeUIImageInstance() {
        for imageName in UIImageName.allCases {
            XCTAssertNotNil(UIImage.image(name: imageName))
        }
    }
}
