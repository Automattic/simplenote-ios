//
//  MigrateKeychain.swift
//  Simplenote
//  Migrates keychain items from previous keychain group
//
import Foundation


// MARK: - KeychainMigrator
//
@objc
class KeychainMigrator: NSObject {

    /// Keychain Constants
    ///
    private struct Constants {
        /// Legacy TeamID
        ///
        static let oldPrefix = "4ESDVWK654."

        /// New TeamID!
        ///
        static let newPrefix = "PZYM8XX95Q."

        /// Main App's Bundle ID
        ///
        static let bundleId = "com.codality.NotationalFlow"

        /// Share Extension's Bundle ID
        ///
        static let shareBundleId = bundleId + ".Share"

        /// Username's User Defaults Key
        ///
        static let usernameKey = "SPUsername"

        /// Legacy TeamID Access Group
        ///
        static let legacyAccessGroup = oldPrefix + bundleId

        /// New TeamID Access Group
        ///
        static let newAccessGroup = newPrefix + bundleId
    }

    /// Local copy of User Defaults
    ///
    private let userDefaults: UserDefaults

    /// Migrates the Legacy Keychain Entry over to the new Access Group
    ///
    @objc
    func migrateIfNecessary() {
        guard needsPasswordMigration() else {
            return
        }

        migrateLegacyPassword()
    }

    @objc
    override init() {
        self.userDefaults = UserDefaults.standard
    }

    @objc
    init(userDefaults: UserDefaults?) {
        self.userDefaults = userDefaults ?? UserDefaults.standard
    }
}


// MARK: - Internal Helpers: This should actually be *private*, but for unit testing purposes, we're keeping them this way.
//
extension KeychainMigrator {

    /// Indicates if the Migration should take place. This is true whenever:
    ///
    /// - The Username is accessible
    /// - There is no current password
    ///
    func needsPasswordMigration() -> Bool {
        guard let username = self.username else {
            return false
        }

        let newKeychainEntry = try? loadKeychainEntry(accessGroup: .new, username: username)
        return newKeychainEntry == nil
    }

    /// Migrates the Keychain Entry associated with the Old TeamID Prefix
    ///
    func migrateLegacyPassword() {
        guard let username = self.username,
            let legacyPassword = try? loadKeychainEntry(accessGroup: .legacy, username: username)
        else {
            return
        }

        // Looks like we need to attempt a migration...
        do {
            try deleteKeychainEntry(accessGroup: .legacy, username: username)
            try saveKeychainEntry(accessGroup: .new, username: username, password: legacyPassword)

            SPTracker.trackKeychainMigrationSucceeded()
        } catch {
            // :(
            NSLog("Keychain Migration Error: \(error)")

            SPTracker.trackKeychainMigrationFailed()
            self.restoreLegacyPassword(password: legacyPassword, for: username)
        }
    }

    /// On error, we'll attempt to restore the legacy Password
    ///
    func restoreLegacyPassword(password: String, for username: String) {
        do {
            try saveKeychainEntry(accessGroup: .legacy, username: username, password: password)
            SPTracker.trackKeychainFailsafeSucceeded()
        } catch {
            NSLog("Keychain Failsafe Error: \(error)")

            SPTracker.trackKeychainFailsafeFailed()
        }
    }
}


// MARK: - User Defaults Wrappers
//
extension KeychainMigrator {
    /// Username
    ///
    var username: String? {
        set {
            userDefaults.set(newValue, forKey: Constants.usernameKey)
            userDefaults.synchronize()
        }
        get {
            return userDefaults.string(forKey: Constants.usernameKey)
        }
    }
}


// MARK: - Keychain Wrappers: This should actually be *private*, but for unit testing purposes, we're keeping them this way.
//
extension KeychainMigrator {

    enum AccessGroup {
        case new
        case legacy

        var stringValue: String {
            switch self {
            case .new:
                return Constants.newAccessGroup
            case .legacy:
                return Constants.legacyAccessGroup
            }
        }
    }

    func loadKeychainEntry(accessGroup: AccessGroup, username: String) throws -> String {
        let passwordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID,
            account: username,
            accessGroup: accessGroup.stringValue
        )

        return try passwordItem.readPassword()
    }

    func deleteKeychainEntry(accessGroup: AccessGroup, username: String) throws {
        let passwordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID,
            account: username,
            accessGroup: accessGroup.stringValue
        )

        try passwordItem.deleteItem()
    }

    func saveKeychainEntry(accessGroup: AccessGroup, username: String, password: String) throws {
        let passwordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID,
            account: username,
            accessGroup: accessGroup.stringValue
        )

        try passwordItem.savePassword(password)
    }

#if RELEASE
    /// This method tests the Migration Flow. This should only be executed in the *Release* target, since the AppID's won't
    /// match with the one(s) used in the other targets.
    ///
    /// For testing purposes only.
    ///
    @objc
    func testMigration() {
        let dummyUsername = "TestingUsername"
        let dummyPassword = "TestingPassword"

        // Recreate Pre-Migration Scenario
        username = dummyUsername
        try? deleteKeychainEntry(accessGroup: .new, username: dummyUsername)
        try? saveKeychainEntry(accessGroup: .legacy, username: dummyUsername, password: dummyPassword)

        // Migrate
        migrateIfNecessary()

        // Verify
        let migrated = try? loadKeychainEntry(accessGroup: .new, username: dummyUsername)
        assert(migrated == dummyPassword)
    }
#endif
}
