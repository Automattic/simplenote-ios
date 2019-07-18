import Foundation
import XCTest
@testable import Simplenote


// MARK: - Options Unit Tests
//
class OptionsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        resetUserDefaults()
    }

    func testEmptyLegacySortSettingsYieldModifiedNewest() {
        let options = Options()
        XCTAssert(options.listSortMode == .modifiedNewest)
    }

    func testLegacyAlphabeticalSortIsProperlyMigrated() {
        UserDefaults.standard.set(true, forKey: .listSortModeLegacy)
        let options = Options()
        XCTAssert(options.listSortMode == .alphabeticallyAscending)
    }
}


// MARK: - Private Methods
//
private extension OptionsTests {

    func resetUserDefaults() {
        guard let identifier = Bundle.main.bundleIdentifier else {
            return
        }

        UserDefaults.standard.removePersistentDomain(forName: identifier)
    }
}
