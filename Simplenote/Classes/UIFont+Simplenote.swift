import Foundation
import UIKit


// MARK: - UIFont Simplenote Helpers
//
extension UIFont {

    /// Returns the System Font for a given Style and Weight
    ///
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)

        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }
}
