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
#if XCODE11
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
#endif

        return VSThemeManager.shared().theme().bool(forKey: kSimplenoteDarkThemeName)
    }
}
