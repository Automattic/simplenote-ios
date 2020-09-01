import Foundation


// MARK: - URL + Interlink
//
extension URL {

    /// Indicates if the receiver is a reference to an internal Note
    ///
    var isInterlinkURL: Bool {
        absoluteString.hasPrefix(SimplenoteConstants.interlinkBaseURL)
    }

    /// Extracts the Internal Note's SimperiumKey, whenever the receiver is an Interlink URL
    ///
    var interlinkSimperiumKey: String? {
        guard isInterlinkURL else {
            return nil
        }

        return absoluteString.replacingOccurrences(of: SimplenoteConstants.interlinkBaseURL, with: "")
    }
}
