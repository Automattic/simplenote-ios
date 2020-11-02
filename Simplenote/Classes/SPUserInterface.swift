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

        return Options.shared.theme == .dark
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
        refreshUIKitAppearance()

        if #available(iOS 13.0, *) {
            refreshUserInterfaceStyleIOS13()
        }
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

    func refreshUIKitAppearance() {
        UIBarButtonItem.refreshAppearance()
        UINavigationBar.refreshAppearance()
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
