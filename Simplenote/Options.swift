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
    /// - Note: Should be *private*, but for unit testing purposes, we're opening this up.
    ///
    override init() {
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
            return SortMode(rawValue: payload) ?? .modifiedNewest
        }
        set {
            defaults.set(newValue.rawValue, forKey: .listSortMode)
            SPTracker.trackSettingsNoteListSortMode(newValue.description)
            NotificationCenter.default.post(name: .SPNotesListSortModeChanged, object: nil)
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
        guard defaults.containsObject(forKey: .listSortMode) == false else {
            return
        }

        let legacySortAlphabetically = defaults.bool(forKey: .listSortModeLegacy)
        let newMode: SortMode = legacySortAlphabetically ? .alphabeticallyAscending : .modifiedNewest

        defaults.set(newMode.rawValue, forKey: .listSortMode)
        defaults.removeObject(forKey: .listSortModeLegacy)
    }
}
