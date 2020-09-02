import Foundation


// MARK: - NSURL + Interlink
//
extension NSURL {

    /// Indicates if the receiver' has the Simplenote Scheme
    ///
    @objc
    var isSimplenoteURL: Bool {
        scheme?.lowercased() == SimplenoteConstants.simplenoteScheme
    }

    /// Indicates if the receiver is a reference to a Note
    ///
    var isInterlinkURL: Bool {
        isSimplenoteURL && host?.lowercased() == SimplenoteConstants.simplenoteInterlinkHost
    }

    /// Extracts the Internal Note's SimperiumKey, whenever the receiver is an Interlink URL
    ///
    @objc
    var interlinkSimperiumKey: String? {
        guard isInterlinkURL else {
            return nil
        }

        return absoluteString?.replacingOccurrences(of: "/", with: "")
    }
}
