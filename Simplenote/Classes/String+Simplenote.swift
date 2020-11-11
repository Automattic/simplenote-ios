import Foundation


// MARK: - String
//
extension String {

    /// Newline
    ///
    static let newline = "\n"

    /// String containing a Space
    ///
    static let space = " "

    /// Tabs
    ///
    static let tab = "\t"
}


// MARK: - Helper API(s)
//
extension String {

    /// Returns the Range enclosing all of the receiver's contents
    ///
    var fullRange: Range<String.Index> {
        startIndex ..< endIndex
    }

    /// Truncates the receiver's full words, up to a specified maximum length.
    /// - Note: Whenever this is not possible (ie. the receiver doesn't have words), regular truncation will be performed
    ///
    func truncateWords(upTo maximumLength: Int) -> String {
        var output = String()

        for word in components(separatedBy: .whitespaces) {
            if (output.count + word.count) >= maximumLength {
                break
            }

            let prefix = output.isEmpty ? String() : .space
            output.append(prefix)
            output.append(word)
        }

        if output.isEmpty {
            return prefix(maximumLength).trimmingCharacters(in: .whitespaces)
        }

        return output
    }
}
