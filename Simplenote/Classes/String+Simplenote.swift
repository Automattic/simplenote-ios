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

    /// Returns a new string dropping specified prefix
    ///
    func droppingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else {
            return self
        }

        return String(dropFirst(prefix.count))
    }
}

// MARK: - Searching for the first / last characters
//
extension String {

    /// Find and return the location of the first / last character from the specified character set
    ///
    func locationOfFirstCharacter(from searchSet: CharacterSet,
                                  startingFrom startLocation: String.Index,
                                  backwards: Bool = false) -> String.Index? {

        guard startLocation <= endIndex else {
            return nil
        }

        let range: Range<String.Index> = {
            if backwards {
                return startIndex..<startLocation
            }

            return startLocation..<endIndex
        }()

        let characterRange = rangeOfCharacter(from: searchSet,
                                              options: backwards ? .backwards : [],
                                              range: range)

        return characterRange?.lowerBound
    }
}
