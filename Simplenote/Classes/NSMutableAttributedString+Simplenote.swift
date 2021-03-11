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
    func apply(color: UIColor, toSubstringsMatching keywords: [String]) {
        guard let excerpt = string.contentSlice(matching: keywords) else {
            return
        }
        for range in excerpt.nsMatches {
            addAttribute(.foregroundColor, value: color, range: range)
        }
    }

    /// Create an attributed string highlighting a term
    ///
    convenience init(string text: String, attributes: [NSAttributedString.Key: Any], highlighting term: String, highlightAttributes: [NSAttributedString.Key: Any]) {
        self.init(string: text, attributes: attributes)

        if let range = text.range(of: term) {
            addAttributes(highlightAttributes, range: NSRange(range, in: text))
        }
    }
}
