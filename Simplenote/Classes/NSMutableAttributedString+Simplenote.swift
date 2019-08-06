import Foundation
import UIKit


// MARK: - NSMutableAttributedString Methods
//
extension NSMutableAttributedString {

    /// Appends a given String with the specified Foreground Color
    ///
    func append(string: String, foregroundColor: UIColor? = nil) {
        var attributes = [NSAttributedString.Key: Any]()
        if let foregroundColor = foregroundColor {
            attributes[.foregroundColor] = foregroundColor
        }

        let suffix = NSAttributedString(string: string, attributes: attributes)
        append(suffix)
    }
}
