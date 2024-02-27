import Foundation

// MARK: - Represents all of the available Themes
//
@objc
enum Theme: Int, CaseIterable {

    /// Darkness!
    ///
    case dark

    /// Old School Light
    ///
    case light

    /// Matches the System Settings
    ///
    case system

    /// Returns a localized Description, matching the current rawValue
    ///
    var description: String {
        switch self {
        case .dark:
            return NSLocalizedString("Dark", comment: "Theme: Dark")
        case .light:
            return NSLocalizedString("Light", comment: "Theme: Light")
        case .system:
            return NSLocalizedString("System Default", comment: "Theme: Matches iOS Settings")
        }
    }
}

extension Theme {

    static var allThemes: [Theme] {
        return [.dark, .light, .system]
    }

    static var legacyThemes: [Theme] {
        return [.dark, .light]
    }

    static var defaultThemeForCurrentOS: Theme {
        return .system
    }
}
