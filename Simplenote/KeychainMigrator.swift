//
//  MigrateKeychain.swift
//  Simplenote
//  Migrates keychain items from previous keychain group

import Foundation

@objc class KeychainMigrator: NSObject {
    static let oldPrefix = "4ESDVWK654."
    static let newPrefix = "PZYM8XX95Q."
    static let bundleId = "com.codality.NotationalFlow"
    static let shareBundleId = bundleId + ".Share"
    static let usernameKey = "SPUsername"

    @objc
    static func migrateIfNecessary() {
        guard let username = UserDefaults.standard.string(forKey: usernameKey) else {
            return
        }

        let newPasswordItem = KeychainPasswordItem(
            service: SPCredentials.simperiumAppID(),
            account: username,
            accessGroup: newPrefix + bundleId
        )
        do {
            try newPasswordItem.readPassword()
            // We have the token!
            return;
        } catch {
            // Looks like we need to attempt a migration...
            let oldPasswordItem = KeychainPasswordItem(
                service: SPCredentials.simperiumAppID(),
                account: username,
                accessGroup: oldPrefix + bundleId
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
}

