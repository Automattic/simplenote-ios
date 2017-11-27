import XCTest
@testable import Simplenote


// MARK: - KeychainMigrator Tests
//
class KeychainMigratorTests: XCTestCase {

    let testingUsername = "TestingUsername"
    let testingPassword = "TestingPassword"


    /// Cleanup
    ///
    override func tearDown() {
        super.tearDown()
        removeUsername()
        removeNewKeychainEntry()
    }

    /// This test verifies that `needsPasswordMigration` returns false whenever the current username is not available.
    ///
    func testNeedsPasswordMigrationReturnsFalseWheneverCurrentUsernameIsMissing() {
        removeUsername()
        XCTAssertFalse(KeychainMigrator.needsPasswordMigration(), "")
    }


    /// This test verifies that `needsPasswordMigration` returns true whenever:
    ///
    /// - Current Username is available
    /// - There is no Keychain entry available for the New TeamID
    ///
    func testNeedsPasswordMigrationReturnsFalseWheneverUsernameIsPresentButCurrentPasswordIsMissing() {
        saveUsername()
        removeNewKeychainEntry()

        XCTAssertTrue(KeychainMigrator.needsPasswordMigration(), "")
    }

    /// This test verifies that the legacy Keychain Entry will be moved over to the new access group whenever:
    ///
    /// - There is an username currently set
    /// - There is no "current" Keychain Entry (tied up to the new access group)
    /// - There is a legacy Keychain entry
    ///
    func testMigrationSucceedsCopyingLegacyKeychainEntry() {
        saveUsername()
        saveLegacyKeychainEntry()
        removeNewKeychainEntry()

        KeychainMigrator.migrateIfNecessary()

        let migratedPassword = loadNewKeychainEntry()
        XCTAssertEqual(migratedPassword, testingPassword)
    }
}


// MARK: - Private Helpers
//
private extension KeychainMigratorTests {

    func loadNewKeychainEntry() -> String? {
        let passwordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: testingUsername,
            accessGroup: KeychainMigrator.newAccessGroup
        )

        return try? passwordItem.readPassword()
    }

    func removeNewKeychainEntry() {
        let passwordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: testingUsername,
            accessGroup: KeychainMigrator.newAccessGroup
        )

        try? passwordItem.deleteItem()
    }

    func saveLegacyKeychainEntry() {
        let oldPasswordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: testingUsername,
            accessGroup: KeychainMigrator.legacyAccessGroup
        )

        try? oldPasswordItem.savePassword(testingPassword)
    }

    func removeUsername() {
        UserDefaults.standard.removeObject(forKey: KeychainMigrator.usernameKey)
    }

    func saveUsername() {
        UserDefaults.standard.set(testingUsername, forKey: KeychainMigrator.usernameKey)
    }
}
