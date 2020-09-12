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

    /// Returns the Note with the specified SimperiumKey
    ///
    @objc(loadNoteWithSimperiumKey:)
    func loadNote(simperiumKey: String) -> Note? {
        return notesBucket.object(forKey: simperiumKey) as? Note
    }
}
