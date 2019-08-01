import Foundation
import XCTest
@testable import Simplenote


// MARK: - Options Unit Tests
//
class OptionsTests: XCTestCase {

    private let suiteName = OptionsTests.classNameWithoutNamespaces.debugDescription
    private lazy var defaults = UserDefaults(suiteName: suiteName)!

    override func setUp() {
        super.setUp()
        defaults.reset()
    }

    func testEmptyLegacySortSettingsYieldModifiedNewest() {
        let options = Options(defaults: defaults)
        XCTAssert(options.listSortMode == .modifiedNewest)
    }

    func testLegacyAlphabeticalSortIsProperlyMigrated() {
        defaults.set(true, forKey: .listSortModeLegacy)
        let options = Options(defaults: defaults)
        XCTAssert(options.listSortMode == .alphabeticallyAscending)
    }

    func testEmptyLegacyThemeYieldsSystemTheme() {
        let options = Options(defaults: defaults)
        XCTAssert(options.theme == .system)
    }

    func testLegacyDarkModeIsProperlyMigrated() {
        defaults.set(true, forKey: .themeLegacy)
        let options = Options(defaults: defaults)
        XCTAssert(options.theme == .dark)
    }

    func testLegacyLightModeIsProperlyMigrated() {
        defaults.set(false, forKey: .themeLegacy)
        let options = Options(defaults: defaults)
        XCTAssert(options.theme == .light)
    }
}

