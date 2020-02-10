import Foundation
import UIKit


// MARK: - NSMutableAttributedString Methods
//
extension NSMutableAttributedString {

    /// Returns the (foundation) associated NSString
    ///
    var foundationString: NSString {
        string as NSString
    }

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

    /// Applies a given UIColor instance to substrings matching a given Keyword
    ///
    func apply(color: UIColor, toSubstringsMatching keywords: String) {
        let maxLength = foundationString.length

        for value in foundationString.ranges(forTerms: keywords) {
            let range = value.rangeValue
            guard NSMaxRange(range) <= maxLength else {
                continue
            }

            addAttribute(.foregroundColor, value: color, range: range)
        }
    }
}
