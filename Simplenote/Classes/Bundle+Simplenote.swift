import Foundation
import UIKit


// MARK: - Bundle: Simplenote Methods
//
extension Bundle {

    /// Returns the Bundle Short Version String.
    ///
    @objc
    var shortVersionString: String {
        let version = infoDictionary?[Keys.shortVersionString] as? String
        return version ?? ""
    }
}


// MARK: - Private Keys
//
private enum Keys {
    static let shortVersionString = "CFBundleShortVersionString"
}
