import Foundation


// MARK: - UIColor Helpers
//
extension UIColor {

    /// Returns the UIColor instance matching a given UIColorName. If any
    ///
    /// - Note: In the spirit of keeping things simple, the Share Extension will only support *System* theme (iOS 13), since the best UX is when we blend in
    ///   with whatever app is initiating the Share sequence. As per `iOS <=12`, we'll simply stick to the Light Theme.
    ///
    /// - Note II: By *keeping things simple* we mean not importing DB5.plist nor the VSTheme machinery.
    ///
    @available (iOS 12, *)
    static func color(name: UIColorName) -> UIColor? {
        return UIColor(named: name.legacyColorKey.rawValue)
    }

    // TODO: Nuke this whenever we bump up the deployment target to (at least) iOS 12
    static func simplenoteBlue() -> UIColor {
        return UIColor(red: 72.0/255.0, green: 149.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    }
}

