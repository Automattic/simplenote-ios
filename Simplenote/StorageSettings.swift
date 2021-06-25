import Foundation

@objcMembers
class StorageSettings: NSObject {

    /// URL for the managed object model resource
    ///
    let modelURL: URL = {
        Bundle.main.url(forResource: Constants.resourceName, withExtension: Constants.resourceType)!
    }()
    /// In app core data storage URL
    ///
    let legacyStorageURL: URL = {
        FileManager.default.documentsURL.appendingPathComponent(Constants.sqlFile)
    }()

    var legacyStorageExists: Bool {
        FileManager.default.fileExists(atPath: legacyStorageURL.path)
    }

    /// URL for core data storage in shared app group documents directory
    ///
    let sharedStorageURL: URL = {
        FileManager.default.sharedContainerURL.appendingPathComponent(Constants.sqlFile)
    }()

    var sharedStorageExists: Bool {
        FileManager.default.fileExists(atPath: sharedStorageURL.path)
    }

    var storageURL: URL {
        if legacyStorageExists && !sharedStorageExists {
            return legacyStorageURL
        }
        return sharedStorageURL
    }
}

private struct Constants {
    static let sqlFile = "Simplenote.sqlite"
    static let resourceName = "Simplenote"
    static let resourceType = "momd"
}
