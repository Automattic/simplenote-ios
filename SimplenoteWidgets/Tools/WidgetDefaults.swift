class WidgetDefaults {

    static let shared = WidgetDefaults()

    private let defaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain)

    private init() { }

    var loggedIn: Bool {
        get {
            defaults?.bool(forKey: .accountIsLoggedIn) ?? false
        }
        set {
            defaults?.set(newValue, forKey: .accountIsLoggedIn)
        }
    }

    var sortMode: SortMode {
        get {
            SortMode(rawValue: defaults?.integer(forKey: .listSortMode) ?? 0) ?? .alphabeticallyAscending
        }
        set {
            let payload = newValue.rawValue
            defaults?.set(payload, forKey: .listSortMode)
        }
    }
}
