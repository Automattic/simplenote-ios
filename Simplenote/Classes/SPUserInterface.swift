import Foundation
import UIKit


// MARK: - Simplenote's Theme
//
@objc
class SPUserInterface: NSObject {

    /// Indicates if the User Interface is in Dark Mode
    ///
    @objc
    static var isDark: Bool {
        guard #available(iOS 13.0, *) else {
            return VSThemeManager.shared().theme().bool(forKey: kSimplenoteDarkThemeName)
        }

        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
