import Foundation
import UIKit


// MARK: - UIBlurEffect Simplenote Methods
//
extension UIBlurEffect {

    /// Returns a UIBlurEffect instance matching the System preferences
    ///
    @objc
    static var simplenoteBlurEffect: UIBlurEffect {
        return UIBlurEffect(style: simplenoteBlurStyle)
    }

    /// Returns the UIBlurEffect.Style matching the System preferences
    ///
    @objc
    static var simplenoteBlurStyle: UIBlurEffect.Style {
        guard #available(iOS 13.0, *) else {
            return SPUserInterface.isDark ? .dark : .light
        }

        return .regular
    }
}
