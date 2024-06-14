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

    func recoveryDirectoryURL() -> URL? {
        let dir = sharedContainerURL.appendingPathComponent(Constants.recoveryDir)

        do {
            try createDirectoryIfNeeded(at: dir)
        } catch {
            NSLog("Could not create recovery directory because: $@", error.localizedDescription)
            return nil
        }

        return dir
    }

    func createDirectoryIfNeeded(at url: URL, withIntermediateDirectories: Bool = true) throws {
        if directoryExistsAtURL(url) {
            return
        }

        try createDirectory(at: url, withIntermediateDirectories: true)
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
