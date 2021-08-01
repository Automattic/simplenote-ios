import Foundation

enum StorageError: Error {
    case appConfigurationError
    case attachingPersistentStoreFailure
    case fetchError
}

extension StorageError {
    /// Returns the Error Title, for Alert purposes
    ///
    var title: String {
        switch self {
        case .appConfigurationError:
            return NSLocalizedString("Main App is not configured", comment: "App configuration error title")
        case .attachingPersistentStoreFailure:
            return NSLocalizedString("Could not attach Persistent Store", comment: "Persistent Store error title")
        case .fetchError:
            return NSLocalizedString("Could not fetch entities", comment: "Fetch error title")
        }
    }

    /// Returns the Error Message, for Alert purposes
    ///
    var message: String {
        switch self {
        case .appConfigurationError:
            return NSLocalizedString("Simplenote must be configured and logged in to setup widgets", comment: "Message displayed when app is not configured")
        case .attachingPersistentStoreFailure:
            return NSLocalizedString("Failed to load persistent store to coordinator", comment: "Message displayed when persistent store load fails")
        case .fetchError:
            return NSLocalizedString("Attempt to fetch entities from core data failed", comment: "Data Fetch error message")
        }
    }
}
