import Foundation


// MARK: - NSURL + Interlink
//
extension NSURL {

    /// Indicates if the receiver is a reference to an internal Note
    ///
    @objc
    var isInterlinkURL: Bool {
        scheme == SimplenoteConstants.interlinkScheme
    }

    /// Extracts the Internal Note's SimperiumKey, whenever the receiver is an Interlink URL
    ///
    @objc
    var interlinkSimperiumKey: String? {
        guard isInterlinkURL else {
            return nil
        }

        return absoluteString?.replacingOccurrences(of: SimplenoteConstants.interlinkBaseURL, with: "")
    }
}
