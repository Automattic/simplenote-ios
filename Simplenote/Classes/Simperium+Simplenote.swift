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
