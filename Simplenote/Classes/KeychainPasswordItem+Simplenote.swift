import Foundation


// MARK: - KeychainPasswordItem + Simplenote API(s)
//
extension KeychainPasswordItem {

    /// Simplenote's PIN Lock Keychain Item
    ///
    static var pinlock: KeychainPasswordItem {
        KeychainPasswordItem(service: SimplenoteKeychain.pinlockService, account: SimplenoteKeychain.pinlockAccount)
    }

    /// Simplenote's Timestamp Keychain Item
    ///
    static var timestamp: KeychainPasswordItem {
        KeychainPasswordItem(service: SimplenoteKeychain.timestampService, account: SimplenoteKeychain.timestampAccount)
    }

    static var shareExtension: KeychainPasswordItem {
        KeychainPasswordItem(service: SimplenoteKeychain.shareExtensionService, account: SimplenoteKeychain.shareExtensionAccount)
    }
}


// MARK: - Keychain Constants
//
enum SimplenoteKeychain {

    /// Pinlock
    ///
    static let pinlockAccount = "SimplenotePin"
    static let pinlockService = pinlockAccount

    /// Timestamp
    ///
    static let timestampAccount = "Main"
    static let timestampService = "simplenote-passcode"

    /// Share Extension
    ///
    static let shareExtensionAccount = "Main"
    static let shareExtensionService = "SimplenoteShare"
}
