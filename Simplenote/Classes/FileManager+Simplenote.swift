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
    var sharedContainerURL: URL {
        containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier)!
    }
}

private struct Constants {
    static let defaultBundleIdentifier = "com.codality.NotationalFlow"
    static let groupIdentifier = Bundle.main.rootBundleIdentifier ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."
}
