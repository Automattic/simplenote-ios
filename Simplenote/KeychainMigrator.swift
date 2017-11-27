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
    /// Legacy TeamID
    ///
    private static let oldPrefix = "4ESDVWK654."

    /// New TeamID!
    ///
    private static let newPrefix = "PZYM8XX95Q."

    /// Main App's Bundle ID
    ///
    private static let bundleId = "com.codality.NotationalFlow"

    /// Share Extension's Bundle ID
    ///
    private static let shareBundleId = bundleId + ".Share"

    /// Username's User Defaults Key
    ///
    static let usernameKey = "SPUsername"

    /// Legacy TeamID Access Group
    ///
    static let legacyAccessGroup = oldPrefix + bundleId

    /// New TeamID Access Group
    ///
    static let newAccessGroup = newPrefix + bundleId


    /// Migrates the Legacy Keychain Entry over to the new Access Group
    ///
    @objc
    static func migrateIfNecessary() {
        guard needsPasswordMigration() else {
            return
        }

        migrateLegacyPassword()
    }
}


// MARK: - Private Methods
//
extension KeychainMigrator {

    /// Indicates if the Migration should take place. This is true whenever:
    ///
    /// - The Username is accessible
    /// - There is no current password
    ///
    static func needsPasswordMigration() -> Bool {
        guard let username = UserDefaults.standard.string(forKey: usernameKey) else {
            return false
        }

        let newPasswordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: username,
            accessGroup: newAccessGroup
        )

        return (try? newPasswordItem.readPassword()) == nil
    }

    /// Migrates the Keychain Entry associated with the Old TeamID Prefix
    ///
    static func migrateLegacyPassword() {
        guard let username = UserDefaults.standard.string(forKey: usernameKey) else {
            return
        }

        // Looks like we need to attempt a migration...
        let oldPasswordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: username,
            accessGroup: legacyAccessGroup
        )

        do {
            let password = try oldPasswordItem.readPassword()
            let migratedPasswordItem = KeychainPasswordItem(
                service: SPCredentials.simperiumAppID(),
                account: username
            )
            try migratedPasswordItem.savePassword(password)
        } catch {
            // :(
        }
    }
}
