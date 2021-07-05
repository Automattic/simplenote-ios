import Foundation

@objcMembers
class StorageSettings: NSObject {

    private let fileManager: FileManager

    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }

    /// URL for the managed object model resource
    ///
    let modelURL = Bundle.main.url(forResource: Constants.resourceName, withExtension: Constants.resourceType)!

    /// In app core data storage URL
    ///
    var legacyStorageURL: URL {
        fileManager.documentsURL.appendingPathComponent(Constants.sqlFile)
    }

    var legacyStorageExists: Bool {
        fileManager.fileExists(atPath: legacyStorageURL.path)
    }

    /// URL for core data storage in shared app group documents directory
    ///
    var sharedStorageURL: URL {
        fileManager.sharedContainerURL.appendingPathComponent(Constants.sqlFile)
    }

    var sharedStorageExists: Bool {
        fileManager.fileExists(atPath: sharedStorageURL.path)
    }

    var storageURL: URL {
        if legacyStorageExists && !sharedStorageExists {
            return legacyStorageURL
        }
        return sharedStorageURL
    }

    let journalModeDisabled = [Constants.journalMode: Constants.journalSetting]
}

private struct Constants {
    static let sqlFile = "Simplenote.sqlite"
    static let resourceName = "Simplenote"
    static let resourceType = "momd"
    static let journalMode = "journal_mode"
    static let journalSetting = "DELETE"
}
