import Foundation

// MARK: - ExcerptMaker: Generate excerpt from text with keywords
//
final class ExcerptMaker {
    private let regexp: NSRegularExpression

    init(keywords: [String]) {
        regexp = NSRegularExpression.regexForExcerpt(withKeywords: keywords)
    }

    func excerpt(from text: String) -> String {
        let nsText = text as NSString
        let range = regexp.rangeOfFirstMatch(in: text, options: [], range: nsText.fullRange)
        guard range.location != NSNotFound else {
            return text
        }
        return nsText.substring(with: range)
    }
}
