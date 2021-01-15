import Foundation


// MARK: - Simperium + Buckets
//
extension Simperium {

    /// Bucket: Account
    /// - Note: Since it's **dynamic** (InMemory JSON Storage), we don't really have an Account class
    ///
    var accountBucket: SPBucket {
        bucket(forName: SimplenoteConstants.accountBucketName)
    }

    /// Bucket: Notes
    ///
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)
    }

    /// Bucket: Preferences
    ///
    @objc
    var preferencesBucket: SPBucket {
        bucket(forName: Preferences.classNameWithoutNamespaces)
    }

    /// Bucket: Settings
    ///
    @objc
    var settingsBucket: SPBucket {
        bucket(forName: Settings.classNameWithoutNamespaces)
    }

    /// Bucket: Tags
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
