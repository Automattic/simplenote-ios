import Foundation

extension NSTextContentManager {
    func textRangeInDocument(for range: NSRange) -> NSTextRange? {
        guard let startLocation = location(documentRange.location, offsetBy: range.location) else {
            return nil
        }

        let endLocation = location(startLocation, offsetBy: range.length)

        return NSTextRange(location: startLocation, end: endLocation)
    }
}
