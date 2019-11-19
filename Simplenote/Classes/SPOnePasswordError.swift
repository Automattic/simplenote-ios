import Foundation
import OnePasswordExtension


// MARK: - SPOnePasswordError
//
enum SPOnePasswordError: Error {
    case onePasswordCancelled
    case onePasswordError
}


// MARK: - SPOnePasswordError Convenience Initializers
//
extension SPOnePasswordError {

    /// Returns the SPAuthError matching a given OnePasswordError (If possible!)
    ///
    init?(onePasswordError: Error?) {
        guard let error = onePasswordError as NSError? else {
            return nil
        }

        self = error.code == AppExtensionErrorCodeCancelledByUser ? .onePasswordError : .onePasswordCancelled
    }
}
