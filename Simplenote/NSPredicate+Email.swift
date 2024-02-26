import Foundation

// MARK: - NSPredicate Validation Methods
//
extension NSPredicate {

    /// Returns a NSPredicate capable of validating Email Addressess
    ///
    static func predicateForEmailValidation() -> NSPredicate {
        let regex = ".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*"
        return NSPredicate(format: "SELF MATCHES %@", regex)
    }
}
