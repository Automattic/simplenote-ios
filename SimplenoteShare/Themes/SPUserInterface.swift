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
        // Note: In the Share Extension we'll always respect the system's theme. iOS <13 will always get light mode.
        guard #available(iOS 13.0, *) else {
            return false
        }

        return UITraitCollection.current.userInterfaceStyle == .dark
    }
}
