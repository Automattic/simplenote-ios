//
//  Options.swift
//  Simplenote
//
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation


// MARK: - Wraps access to all of the UserDefault Values
//
class Options: NSObject {

    /// Shared Instance
    ///
    @objc
    static let shared = Options()

    /// User Defaults: Convenience
    ///
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }

    /// Designated Initializer
    ///
    override private init() {
        super.init()
        migrateLegacyOptions()
    }
}


// MARK: - Actual Options!
//
extension Options {

    /// Returns the target Sort Mode for the Notes List
    ///
    @objc
    var listSortMode: SortMode {
        get {
            let payload = defaults.integer(forKey: .listSortMode)
            return SortMode(rawValue: payload) ?? .alphabeticallyAscending
        }
        set {
            defaults.set(newValue.rawValue, forKey: .listSortMode)
        }
    }
}


// MARK: - ObjC Convenience Methods
//
extension Options {

    /// Returns the *Description* for the current List's Sort Mode
    ///
    @objc
    var listSortModeDescription: String {
        return listSortMode.description
    }
}


// MARK: - Private
//
private extension Options {

    func migrateLegacyOptions() {
        guard let legacySortAscending: Bool = defaults[.listSortModeLegacy] else {
            return
        }

        let newMode: SortMode = legacySortAscending ? .alphabeticallyAscending : .alphabeticallyDescending
        defaults.set(newMode, forKey: .listSortMode)
        defaults.removeObject(forKey: .listSortModeLegacy)
    }
}
