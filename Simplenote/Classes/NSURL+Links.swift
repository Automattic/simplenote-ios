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

        return path?.replacingOccurrences(of: "/", with: "")
    }

    /// Indicates if the receiver is a reference to a tag
    ///
    @objc
    var isInternalTagURL: Bool {
        isSimplenoteURL && host?.lowercased() == SimplenoteConstants.simplenoteInternalTagHost
    }

    /// Extracts the tag,  whenever the receiver is an internal tag url
    ///
    @objc
    var internalTagKey: String? {
        guard isInternalTagURL else {
            return nil
        }

        return query?.replacingOccurrences(of: "tag=", with: "")
    }
}
