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
    private let defaults: UserDefaults



    /// Designated Initializer
    ///
    /// - Note: Should be *private*, but for unit testing purposes, we're opening this up.
    ///
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        super.init()
        migrateLegacyOptions()
        migrateLegacyTheme()
    }
}


// MARK: - Actual Options!
//
extension Options {

    /// Indicates if the Notes List should be condensed (or not)
    ///
    @objc
    var condensedNotesList: Bool {
        get {
            return defaults.bool(forKey: .condensedNotes)
        }
        set {
            defaults.set(newValue, forKey: .condensedNotes)
            NotificationCenter.default.post(name: .SPCondensedNoteListPreferenceChanged, object: nil)
        }
    }

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

    /// Returns the Search's Sort Mode. When it's undefined we'll fallback to the List's Sort Mode
    ///
    @objc
    var searchSortMode: SortMode {
        get {
            guard defaults.containsObject(forKey: .searchSortMode) else {
                return listSortMode
            }

            let payload = defaults.integer(forKey: .searchSortMode)
            return SortMode(rawValue: payload) ?? .alphabeticallyAscending
        }
        set {
            defaults.set(newValue.rawValue, forKey: .searchSortMode)
            SPTracker.trackSettingsSearchSortMode(newValue.description)
            NotificationCenter.default.post(name: .SPSearchSortModeChanged, object: nil)
        }
    }

    /// Returns the selected Theme
    ///
    @objc
    var theme: Theme {
        get {
            guard defaults.containsObject(forKey: .theme) else {
                return Theme.defaultThemeForCurrentOS
            }

            let payload = defaults.integer(forKey: .theme)
            return Theme(rawValue: payload) ?? Theme.defaultThemeForCurrentOS
        }
        set {
            defaults.set(newValue.rawValue, forKey: .theme)
            NotificationCenter.default.post(name: .SPSimplenoteThemeChanged, object: nil)
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

    /// Returns the *Description* for the current List's Sort Mode
    ///
    @objc
    var themeDescription: String {
        return theme.description
    }

    /// Nukes all of the Options. Useful for *logout* scenarios
    ///
    @objc
    func reset() {
        defaults.removeObject(forKey: .theme)
        defaults.removeObject(forKey: .listSortMode)
        defaults.removeObject(forKey: .searchSortMode)
    }
    
    /// Returns the number of Preview Lines we should use, per note
    ///
    @objc
    var numberOfPreviewLines: Int {
        return condensedNotesList ? Settings.numberOfPreviewLinesCondensed : Settings.numberOfPreviewLinesRegular
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

    func migrateLegacyTheme() {
        guard defaults.containsObject(forKey: .theme) == false, defaults.containsObject(forKey: .themeLegacy) else {
            return
        }

        let newTheme: Theme = defaults.bool(forKey: .themeLegacy) ? .dark : .light
        defaults.set(newTheme.rawValue, forKey: .theme)
    }
}


// MARK: - Constants!
//
private enum Settings {
    static let numberOfPreviewLinesRegular = 3
    static let numberOfPreviewLinesCondensed = 1
}
