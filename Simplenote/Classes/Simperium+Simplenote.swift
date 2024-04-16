import Foundation

// MARK: - Simperium + Buckets
//
extension Simperium {

    var allBuckets: [SPBucket] {
        [ accountBucket, notesBucket, preferencesBucket, settingsBucket, tagsBucket ]
    }

    /// Bucket: Account
    /// - Note: Since it's **dynamic** (InMemory JSON Storage), we don't really have an Account class
    ///
    @objc
    var accountBucket: SPBucket {
        bucket(forName: Simperium.accountBucketName)!
    }

    /// Bucket: Notes
    ///
    @objc
    var notesBucket: SPBucket {
        bucket(forName: Note.classNameWithoutNamespaces)!
    }

    /// Bucket: Preferences
    ///
    @objc
    var preferencesBucket: SPBucket {
        bucket(forName: Preferences.classNameWithoutNamespaces)!
    }

    /// Bucket: Settings
    ///
    @objc
    var settingsBucket: SPBucket {
        bucket(forName: Settings.classNameWithoutNamespaces)!
    }

    /// Bucket: Tags
    ///
    @objc
    var tagsBucket: SPBucket {
        bucket(forName: Tag.classNameWithoutNamespaces)!
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

// MARK: - Constants
//
extension Simperium {
    static let accountBucketName = "Account"
    static let preferencesLastChangedSignatureKey = "lastChangeSignature-Preferences"
}
