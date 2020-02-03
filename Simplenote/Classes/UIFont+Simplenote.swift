import Foundation
import UIKit


// MARK: - UIFont Simplenote Helpers
//
extension UIFont {

    /// Returns the System Font for a given Style and Weight
    ///
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        if let cachedFont = FontCache.cachedFont(for: style, weight: weight) {
            return cachedFont
        }

        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let unstyledFont = UIFont.systemFont(ofSize: descriptor.pointSize, weight: weight)
        let preferredFont = UIFontMetrics(forTextStyle: style).scaledFont(for: unstyledFont)

        FontCache.storeFont(preferredFont, style: style, weight: weight)

        return preferredFont
    }
}


// MARK: - FontCache: Performance Helper!
//
private enum FontCache {

    /// Internal Cache
    ///
    private static var cache = [UIFont.TextStyle: [UIFont.Weight: UIFont]]()

    /// Returns the stored entry for the specified Style + Weight combination (If Any!)
    /// - Note: This method is, definitely, non threadsafe!
    ///
    static func cachedFont(for style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont? {
        assert(Thread.isMainThread)

        return cache[style]?[weight]
    }

    /// Stores a given UIFont instance, under the specified Style and Weight keys
    /// - Note: This method is, definitely, non threadsafe!
    ///
    static func storeFont(_ font: UIFont, style: UIFont.TextStyle, weight: UIFont.Weight) {
        assert(Thread.isMainThread)

        var updatedStyleMap = cache[style] ?? [:]
        updatedStyleMap[weight] = font
        cache[style] = updatedStyleMap
    }
}
