import Foundation
import UIKit


// MARK: - Simplenote's Theme
//
@objc
class SPUserInterface: NSObject {

    /// Ladies and gentlemen, this is a singleton.
    ///
    @objc
    static let shared = SPUserInterface()

    /// Indicates if the User Interface is in Dark Mode
    ///
    @objc
    static var isDark: Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }

        return VSThemeManager.shared().theme().bool(forKey: kSimplenoteDarkThemeName)
    }

    /// Deinitializer
    ///
    deinit {
        stopListeningToNotifications()
    }

    /// Initializer
    ///
    private override init() {
        super.init()
        startListeningToNotifications()
    }

    /// Refreshes the UI so that it matches the latest Options.theme value
    ///
    @objc
    func refreshUserInterfaceStyle() {
        guard #available(iOS 13.0, *) else {
            refreshUserInterfaceStyleIOS12()
            return
        }

        refreshUserInterfaceStyleIOS13()
    }
}


// MARK: - Private Methods
//
private extension SPUserInterface {

    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refreshUserInterfaceStyle), name: .SPSimplenoteThemeChanged, object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    func refreshUserInterfaceStyleIOS12() {
        let legacyThemeName = Options.shared.theme == .dark ? kSimplenoteDarkThemeName : kSimplenoteDefaultThemeName
        VSThemeManager.shared().swapTheme(legacyThemeName)
    }
    
    @available (iOS 13, *)
    func refreshUserInterfaceStyleIOS13() {
        let window = SPAppDelegate.shared().window
        window.overrideUserInterfaceStyle = Options.shared.theme.userInterfaceStyle
    }
}


// MARK: - Private Theme Methods
//
private extension Theme {

    @available (iOS 13, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return .unspecified
        }
    }
}
