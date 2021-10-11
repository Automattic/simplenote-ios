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
        UITraitCollection.current.userInterfaceStyle == .dark
    }
}
