import Foundation
import UIKit


// MARK: - Simplenote's UIImage Static Methods
//
extension UIImage {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func image(name: UIImageName) -> UIImage? {
        let lightName = name.lightAssetFilename
        let darthName = name.darkAssetFilename

        /// In iOS <13 we just instantiate a single asset, matching the current appearance. Fallback to Light, always.
        ///
        guard #available(iOS 13.0, *) else {
            let name = (SPUserInterface.isDark ? darthName : lightName) ?? lightName
            return UIImage(named: name)
        }

        /// iOS +13 returns a dynamic asset!
        ///
        return UIImage(named: lightName)
    }
}
