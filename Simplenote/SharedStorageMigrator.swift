import Foundation
import CoreData
import AutomatticTracks

@objc
class SharedStorageMigrator: NSObject {
    private let storageSettings: StorageSettings
    private let fileManager: FileManager

    init(storageSettings: StorageSettings = StorageSettings(), fileManager: FileManager = FileManager.default) {
        self.storageSettings = storageSettings
        self.fileManager = fileManager
    }

    var legacyStorageExists: Bool {
        fileManager.fileExists(atPath: storageSettings.legacyStorageURL.path)
    }

    var sharedStorageExists: Bool {
        fileManager.fileExists(atPath: storageSettings.sharedStorageURL.path)
    }

    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup

    @objc
    func performMigrationIfNeeded() {
        // Confirm if the app group DB exists
        guard migrationNeeded else {
            NSLog("Core Data Migration not required")
            return
        }

        migrateCoreDataToAppGroup()
    }

    private var migrationNeeded: Bool {
        return legacyStorageExists && !sharedStorageExists
    }

    private func migrateCoreDataToAppGroup() {
        // Testing prints
        // TODO: Remove prints later
        print("oldDb exists \(FileManager.default.fileExists(atPath: storageSettings.legacyStorageURL.path))")
        print(storageSettings.legacyStorageURL.path)
        print("newDb exists \(FileManager.default.fileExists(atPath: storageSettings.sharedStorageURL.path))")
        print(storageSettings.sharedStorageURL.path)

        NSLog("Database needs migration to app group")
        NSLog("Beginning database migration")

        do {
            try disableJournaling()
            try migrateCoreDataFiles()
            NSLog("Database migration successful!!")
        } catch {
            NSLog("Could not migrate database to app group")
            NSLog(error.localizedDescription)
            CrashLogging.logError(error)
        }
    }

    private func disableJournaling() throws {
        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL) else {
            return
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

        let options = [NSSQLitePragmasOption: storageSettings.journalModeDisabled] as [AnyHashable: Any]

        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                   configurationName: nil,
                                   at: storageSettings.legacyStorageURL,
                                   options: options)

        // Remove the persistent store before exiting
        // If removing fails, the migration can still continue so not throwing the errors
        do {
            for store in psc.persistentStores {
                try psc.remove(store)
            }
        } catch {
            NSLog("Could not remove temporary persistent Store")
            NSLog(error.localizedDescription)
        }
    }

    private func migrateCoreDataFiles() throws {
        try FileManager.default.copyItem(at: storageSettings.legacyStorageURL, to: storageSettings.sharedStorageURL)
    }
}
