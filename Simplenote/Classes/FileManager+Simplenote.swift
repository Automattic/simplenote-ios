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
        containerURL(forSecurityApplicationGroupIdentifier: SimplenoteConstants.sharedGroupDomain)!
    }

    var recoveryDirectoryURL: URL {
        sharedContainerURL.appendingPathComponent(Constants.recoveryDir)
    }

    func directoryExistsAtURL(_ url: URL) -> Bool {
        var isDir: ObjCBool = false
        let exists = self.fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }
}

private struct Constants {
    static let recoveryDir = "Recovery"
}
