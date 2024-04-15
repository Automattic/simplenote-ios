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

    /// Indicates if it's the First Launch event was already handled
    ///
    @objc
    var firstLaunch: Bool {
        get {
            defaults.bool(forKey: .firstLaunch)
        }
        set {
            defaults.set(newValue, forKey: .firstLaunch)
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

    /// Indicates if Markdown should be enabled by default in new documents
    ///
    @objc
    var markdown: Bool {
        get {
            defaults.bool(forKey: .markdown)
        }
        set {
            defaults.set(newValue, forKey: .markdown)
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
            SPTracker.trackSettingsThemeUpdated(newValue.description)
            NotificationCenter.default.post(name: .SPSimplenoteThemeChanged, object: nil)
        }
    }

    var useBiometryInsteadOfPin: Bool {
        get {
            defaults.bool(forKey: .useBiometryInsteadOfPin)
        }

        set {
            defaults.set(newValue, forKey: .useBiometryInsteadOfPin)
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
        defaults.removeObject(forKey: .markdown)
        defaults.removeObject(forKey: .useBiometryInsteadOfPin)
    }

    /// Returns the number of Preview Lines we should use, per note
    ///
    @objc
    var numberOfPreviewLines: Int {
        return condensedNotesList ? Settings.numberOfPreviewLinesCondensed : Settings.numberOfPreviewLinesRegular
    }

    /// Index notes in spotlight
    ///
    @objc
    var indexNotesInSpotlight: Bool {
        get {
            defaults.bool(forKey: .indexNotesInSpotlight)
        }

        set {
            defaults.set(newValue, forKey: .indexNotesInSpotlight)
        }
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
