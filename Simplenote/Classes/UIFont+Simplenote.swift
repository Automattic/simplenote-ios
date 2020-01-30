import Foundation
import UIKit


// MARK: - UIFont Simplenote Helpers
//
extension UIFont {

    /// Default Asset Height Multiplier
    ///
    static let defaultInlineAssetSizeMultiplier = CGFloat(0.7)

    /// Returns the System Font for a given Style and Weight
    ///
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)

        return UIFontMetrics(forTextStyle: style).scaledFont(for: font)
    }

    /// Returns the (Expected) InlineAsset Height: We consider the lineHeight, and apply a (default) multiplier, to account for ascending and descending metrics.
    ///
    func inlineAssetHeight(multiplier: CGFloat = defaultInlineAssetSizeMultiplier) -> CGFloat {
        return ceil(lineHeight * multiplier)
    }
}
