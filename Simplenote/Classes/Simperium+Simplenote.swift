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
    var accountBucket: SPBucket {
        bucket(forName: Simperium.accountBucketName)
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


// MARK: - System Entities
//
extension Simperium {

    /// Returns the Email Verification Entity, if it's been Sync'ed (and can be parsed)
    ///
    var emailVerificationEntity: EmailVerification? {
        guard let payload = accountBucket.object(forKey: SPCredentials.simperiumEmailVerificationObjectKey) as? [AnyHashable: Any] else {
            return nil
        }

        return EmailVerification(payload: payload)
    }
}


// MARK: - Constants
//
extension Simperium {
    static let accountBucketName = "Account"
}
