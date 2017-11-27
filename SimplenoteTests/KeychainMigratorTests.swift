import XCTest
@testable import Simplenote


// MARK: - KeychainMigrator Tests
//
class KeychainMigratorTests: XCTestCase {

    let testingUsername = "TestingUsername"
    let testingPassword = "TestingPassword"
    let migrator = KeychainMigrator()

    /// Cleanup
    ///
    override func tearDown() {
        super.tearDown()

        migrator.username = nil
        try? migrator.deleteKeychainEntry(accessGroup: .new, username: testingUsername)
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
