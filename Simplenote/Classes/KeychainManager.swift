import Foundation

// MARK: - KeychainManager
//
enum KeychainManager {

    /// Simplenote's Share Extension Token
    ///
    @KeychainItemWrapper(service: SimplenoteKeychain.extensionService, account: SimplenoteKeychain.extensionAccount)
    static var extensionToken: String?

    /// Simplenote's PIN Lock Keychain Item
    ///
    @KeychainItemWrapper(service: SimplenoteKeychain.pinlockService, account: SimplenoteKeychain.pinlockAccount)
    static var pinlock: String?

    /// Simplenote's Timestamp Keychain Item
    ///
    @KeychainItemWrapper(service: SimplenoteKeychain.timestampService, account: SimplenoteKeychain.timestampAccount)
    static var timestamp: String?
}

// MARK: - KeychainItemWrapper
//
@propertyWrapper
struct KeychainItemWrapper {

    let item: KeychainPasswordItem

    /// Designated Initializer
    ///
    init(service: String, account: String) {
        item = KeychainPasswordItem(service: service, account: account)
    }

    var wrappedValue: String? {
        mutating get {
            do {
                return try item.readPassword()

            } catch KeychainError.noPassword {
                return nil

            } catch {
                NSLog("Error Reading Keychain Item \(item.service).\(item.account): \(error)")
                return nil
            }
        }
        set {
            do {
                if let value = newValue {
                    try item.savePassword(value)
                } else {
                    try item.deleteItem()
                }
            } catch {
                NSLog("Error Setting Keychain Item \(item.service).\(item.account)")
            }
        }
    }
}

// MARK: - Keychain Constants
//
enum SimplenoteKeychain {

    /// Extension Token
    ///
    static let extensionAccount = "Main"
    static let extensionService = "SimplenoteShare"

    /// Pinlock
    ///
    static let pinlockAccount = "SimplenotePin"
    static let pinlockService = pinlockAccount

    /// Timestamp
    ///
    static let timestampAccount = "Main"
    static let timestampService = "simplenote-passcode"
}
