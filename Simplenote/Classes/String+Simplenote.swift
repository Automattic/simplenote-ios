import Foundation


// MARK: - String
//
extension String {

    /// Returns the Search Operator we should recognize, when filtering out entities with a given Tag
    ///
    static let searchOperatorForTags = NSLocalizedString("tag:", comment: "Search Operator for tags. Please preserve the semicolons when translating!")

    /// Newline
    ///
    static let newline = "\n"

    /// String containing a Space
    ///
    static let space = " "

    /// Tabs
    ///
    static let tab = "\t"


    /// Returns the Suffix string after a given `prefix` (if any!)
    ///
    func suffix(afterPrefix prefix: String) -> String? {
        guard hasPrefix(prefix), count >= prefix.count else {
            return nil
        }

        return String(dropFirst(prefix.count))
    }

    /// Replaces the last word in the receiver (tokens are separated by whitespaces)
    ///
    func replaceLastWord(with word: String) -> String {
        var words = components(separatedBy: .whitespaces).dropLast()
        words.append(word)

        return words.joined(separator: .space)
    }
}
