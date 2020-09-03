import Foundation


// MARK: - Simperium + Buckets
//
extension Simperium {

    /// Notes Bucket
    ///
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)
    }

    /// Tags Bucket
    ///
    @objc
    var tagsBucket: SPBucket {
        bucket(forName: Tag.classNameWithoutNamespaces)
    }
}


// MARK: - Public API(s)
//
extension Simperium {

    /// Returns the Note associated with the specified URL
    ///
    @objc
    func loadNote(for url: NSURL) -> Note? {
        guard let simperiumKey = url.interlinkSimperiumKey else {
            return nil
        }

        return notesBucket.object(forKey: simperiumKey) as? Note
    }
}
