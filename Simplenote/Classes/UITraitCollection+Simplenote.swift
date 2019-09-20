import Foundation
import UIKit


// MARK: - UITraitCollection Simplenote Methods
//
extension UITraitCollection {

    /// Returns a UITraitCollection that *only* contains the Light Interface Style. No other attribute is initialized
    ///
    @available(iOS 12.0, *)
    static var purelyLightTraits: UITraitCollection {
        UITraitCollection(userInterfaceStyle: .light)
    }

    /// Returns a UITraitCollection that *only* contains the Dark Interface Style. No other attribute is initialized
    ///
    @available(iOS 12.0, *)
    static var purelyDarkTraits: UITraitCollection {
        UITraitCollection(userInterfaceStyle: .dark)
    }
}
