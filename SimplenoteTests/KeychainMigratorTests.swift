import XCTest
@testable import Simplenote


// MARK: - KeychainMigrator Tests
//
class KeychainMigratorTests: XCTestCase {

    let testingUsername = "TestingUsername"
    let testingPassword = "TestingPassword"
    let testDefaults = UserDefaults(suiteName: TestConstants.suiteName)
    lazy var migrator = KeychainMigrator(userDefaults: testDefaults)

    /// Cleanup
    ///
    override func tearDown() {
        super.tearDown()

        migrator.username = nil
        try? migrator.deleteKeychainEntry(accessGroup: .new, username: testingUsername)
        testDefaults?.removePersistentDomain(forName: TestConstants.presistentDomainName)
    }

    /// This test verifies that `needsPasswordMigration` returns false whenever the current username is not available.
    ///
    func testNeedsPasswordMigrationReturnsFalseWheneverCurrentUsernameIsMissing() {
        migrator.username = nil
        XCTAssertFalse(migrator.needsPasswordMigration(), "")
    }


    /// This test verifies that `needsPasswordMigration` returns true whenever:
    ///
    /// - Current Username is available
    /// - There is no Keychain entry available for the New TeamID
    ///
    func testNeedsPasswordMigrationReturnsFalseWheneverUsernameIsPresentButCurrentPasswordIsMissing() {
        migrator.username = testingUsername
        try? migrator.deleteKeychainEntry(accessGroup: .new, username: testingUsername)

        XCTAssertTrue(migrator.needsPasswordMigration(), "")
    }
}

private struct TestConstants {
    static let presistentDomainName = "com.codality.NotationalFlow"
    static let suiteName = "SimplenoteTests"
}
