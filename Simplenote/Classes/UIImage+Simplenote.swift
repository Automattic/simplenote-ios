import Foundation
import UIKit


// MARK: - Simplenote's UIImage Static Methods
//
extension UIImage {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    @objc
    static func image(name: UIImageName) -> UIImage? {
        UIImage(named: name.lightAssetFilename)
    }
}
