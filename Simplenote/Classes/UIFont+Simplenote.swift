import Foundation
import UIKit

// MARK: - UIFont Simplenote Helpers
//
extension UIFont {

    /// Default Asset Height Multiplier
    ///
    static let defaultInlineAssetSizeMultiplier = CGFloat(0.7)

    /// Returns the (Expected) InlineAsset Height: We consider the lineHeight, and apply a (default) multiplier, to account for ascending and descending metrics.
    ///
    func inlineAssetHeight(multiplier: CGFloat = defaultInlineAssetSizeMultiplier) -> CGFloat {
        return ceil(lineHeight * multiplier)
    }

    /// Returns the System Font for a given Style and Weight
    ///
    @objc
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        if let cachedFont = FontCache.shared.cachedFont(for: style, weight: weight) {
            return cachedFont
        }

        let preferredFont = uncachedPreferredFont(for: style, weight: weight)
        FontCache.shared.storeFont(preferredFont, style: style, weight: weight)

        return preferredFont
    }

    ///
    ///
    private static func uncachedPreferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let descriptor = UIFontDescriptor
                            .preferredFontDescriptor(withTextStyle: style)
                            .addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])

        return UIFont(descriptor: descriptor, size: .zero)
    }

    /// Returns Italic version of the font
    ///
    func italic() -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: .zero)
    }
}

// MARK: - FontCache: Performance Helper!
//
private class FontCache {

    /// Internal Cache
    ///
    private var cache = [UIFont.TextStyle: [UIFont.Weight: UIFont]]()

    /// Yes. Another Singleton!
    ///
    static let shared = FontCache()

    /// (Private) Initializer
    ///
    private init() {
        startListeningToNotifications()
    }

    /// Returns the stored entry for the specified Style + Weight combination (If Any!)
    /// - Note: This method is, definitely, non threadsafe!
    ///
    func cachedFont(for style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont? {
        assert(Thread.isMainThread)

        return cache[style]?[weight]
    }

    /// Stores a given UIFont instance, under the specified Style and Weight keys
    /// - Note: This method is, definitely, non threadsafe!
    ///
    func storeFont(_ font: UIFont, style: UIFont.TextStyle, weight: UIFont.Weight) {
        assert(Thread.isMainThread)

        var updatedStyleMap = cache[style] ?? [:]
        updatedStyleMap[weight] = font
        cache[style] = updatedStyleMap
    }
}

// MARK: - Private Methods
//
private extension FontCache {

    func startListeningToNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    @objc
    func contentSizeCategoryDidChange() {
        cache.removeAll()
    }
}
