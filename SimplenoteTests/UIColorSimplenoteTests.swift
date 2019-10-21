import XCTest
@testable import Simplenote


// MARK: - UIColor+Simplenote Unit Tests
//
class UIColorSimplenoteTests: XCTestCase {

    /// Verify every single UIColorName in existance yields a valid UIColor instancce
    ///
    func testEverySingleUIColorNameEffectivelyYieldsSomeUIColorInstance() {
        for colorName in UIColorName.allCases {
            XCTAssertNotNil(UIColor.color(name: colorName))
        }
    }

    /// Verify every single UIColorName in existance yields a valid UIColor instancce
    ///
    func testUIColorInstancesObtainedViaUIColorNameResolveToLightAndDarkModeEffectiveColors() {
        guard #available(iOS 13, *) else {
            return
        }

        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)

        for colorName in UIColorName.allCases {
            let unresolvedColor = UIColor.color(name: colorName)
            XCTAssertNotNil(unresolvedColor)

            let lightColor = unresolvedColor?.resolvedColor(with: lightTraits)
            XCTAssertNotNil(lightColor)

            let darkColor = unresolvedColor?.resolvedColor(with: darkTraits)
            XCTAssertNotNil(darkColor)
        }
    }
}
