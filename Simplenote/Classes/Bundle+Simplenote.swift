import Foundation
import UIKit


// MARK: - Bundle: Simplenote Methods
//
extension Bundle {

    /// Returns the Bundle Short Version String.
    ///
    @objc
    var shortVersionString: String {
        let version = infoDictionary?[Keys.shortVersionString] as? String
        return version ?? ""
    }
}

extension Bundle {

    /// Returns the BundleIdentifier
    /// - Important:
    ///     - When invoked from an App Extension, this API will attempt to determine the "Parent App" Bundle identifier
    ///     - You must also make sure App Extension targets contain the `APP_EXTENSION` constant, in the "active compilation conditions" project settings
    ///
    var rootBundleIdentifier: String? {
        guard isAppExtensionBundle else {
            return bundleIdentifier
        }

        let url = bundleURL.deletingLastPathComponent().deletingLastPathComponent()
        let rootIdentifier = Bundle(url: url)?.object(forInfoDictionaryKey: kCFBundleIdentifierKey as String)
        return rootIdentifier as? String
    }
}


// MARK: - Private Helpers
//
private extension Bundle {

    var isAppExtensionBundle: Bool {
    #if APP_EXTENSION
        return true
    #else
        return false
    #endif
    }
}

// MARK: - Private Keys
//
private enum Keys {
    static let shortVersionString = "CFBundleShortVersionString"
}
