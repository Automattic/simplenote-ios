import Foundation
import UIKit


// MARK: - Simplenote's UIImage Static Methods
//
extension UIImage {

    /// Returns the One Password Icon
    ///
    @objc
    static var onePasswordImage: UIImage {
        return UIImage(named: "button_onepassword")!
    }

    /// Returns the Pinned Icon, to be used by the Notes List
    ///
    @objc
    static var pinImage: UIImage {
        return UIImage(named: "icon_pin")!
    }

    /// Returns the Shared Icon, to be used by the Notes List
    ///
    @objc
    static var sharedImage: UIImage {
        return UIImage(named: "icon_shared")!
    }

    /// Returns the Visibility On Image
    ///
    @objc
    static var visibilityOnImage: UIImage {
        return UIImage(named: "button_visibility_on")!
    }

    /// Returns the Visibility Off Image
    ///
    @objc
    static var visibilityOffImage: UIImage {
        return UIImage(named: "button_visibility_off")!
    }
}
