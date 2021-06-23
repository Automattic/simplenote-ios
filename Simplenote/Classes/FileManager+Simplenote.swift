import Foundation

// MARK: - FileManager
//
extension FileManager {

     /// User's Document Directory
     ///
     var documentsURL: URL {
         guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
             fatalError("Cannot Access User Documents Directory")
         }

         return url
     }

    /// URL for Simplenote's shared app group directory
    ///
    var groupDirectory: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier)!
    }

    /// URL for Simplenote's shared app group documents directory
    ///
    var groupDocumentsDirectory: URL {
        groupDirectory.appendingPathComponent(Constants.documentDirectory)
    }
}

private struct Constants {
    static let defaultBundleIdentifier = "com.codality.NationalFlow"
    static let groupIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."
    static let documentDirectory = "Documents"
}
