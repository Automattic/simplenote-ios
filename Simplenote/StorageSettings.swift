import Foundation

@objcMembers
class StorageSettings: NSObject {

    private let fileManager: FileManager

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    /// URL for the managed object model resource
    ///
    let modelURL = Bundle.main.url(forResource: Constants.modelName, withExtension: Constants.modelExtension)!

    /// In app core data storage URL
    ///
    var legacyStorageURL: URL {
        fileManager.documentsURL.appendingPathComponent(Constants.sqlFile)
    }

    /// URL for core data storage in shared app group documents directory
    ///
    var sharedStorageURL: URL {
        fileManager.sharedContainerURL.appendingPathComponent(Constants.sqlFile)
    }

    /// URL for backing up the legacy storage
    ///
    var legacyBackupURL: URL {
        legacyStorageURL.appendingPathExtension(Constants.oldExtension)
    }
}

private struct Constants {
    static let sqlFile = "Simplenote.sqlite"
    static let modelName = "Simplenote"
    static let modelExtension = "momd"
    static let oldExtension = "old"
}
