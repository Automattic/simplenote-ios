import Foundation
import UIKit


/// Bundle: Woo Methods
///
extension Bundle {

    /// Returns the Bundle Short Version String.
    ///
    @objc
    var shortVersionString: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? ""
    }
}
