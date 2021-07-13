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

    private var legacyStorageExists: Bool {
        fileManager.fileExists(atPath: storageSettings.legacyStorageURL.path)
    }

    private var sharedStorageExists: Bool {
        fileManager.fileExists(atPath: storageSettings.sharedStorageURL.path)
    }

    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup

    func performMigrationIfNeeded() -> MigrationResult {
        // Confirm if the app group DB exists
        guard migrationNeeded else {
            NSLog("Core Data Migration not required")
            return .notNeeded
        }

        return migrateCoreDataToAppGroup()
    }

    private var migrationNeeded: Bool {
        return legacyStorageExists && !sharedStorageExists
    }

    private func migrateCoreDataToAppGroup() -> MigrationResult {
        NSLog("Database needs migration to app group")
        NSLog("Beginning database migration from: \(storageSettings.legacyStorageURL.path) to: \(storageSettings.sharedStorageURL.path)")

        do {
            try disableJournaling()
            try migrateCoreDataFiles()
            try attemptCreationOfCoreDataStack()
            NSLog("Database migration successful!!")
            backupLegacyDatabase()
            return .success
        } catch {
            NSLog("Could not migrate database to app group " + error.localizedDescription)
            CrashLogging.logError(error)

            removeFailedMigrationFilesIfNeeded()
            return .failed
        }
    }

    /// This method disables journaling on the core data database
    /// Per this doc: https://developer.apple.com/library/archive/qa/qa1809/_index.html
    /// Core data databases have journaling enabled by default, without disabling the journaling first it is possible some notes may get lost in migration
    ///
    private func disableJournaling() throws {
        NSLog("Attempting to disable journaling on persistent store at \(storageSettings.legacyStorageURL)")
        try loadPersistentStorage(at: storageSettings.legacyStorageURL, journaling: false)
    }

    private func loadPersistentStorage(at storagePath: URL, journaling: Bool) throws {
        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL) else {
            fatalError("Could not load Managed Object Model at path: \(storagePath.path)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

        let options = journaling ? nil : [NSSQLitePragmasOption: Constants.journalModeDisabled]

        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                   configurationName: nil,
                                   at: storagePath,
                                   options: options)

        // Remove the persistent store before exiting
        // If removing fails, the migration can still continue so not throwing the errors
        do {
            for store in psc.persistentStores {
                try psc.remove(store)
            }
        } catch {
            NSLog("Could not remove temporary persistent Store " + error.localizedDescription)
        }
    }

    private func migrateCoreDataFiles() throws {
        try fileManager.copyItem(at: storageSettings.legacyStorageURL, to: storageSettings.sharedStorageURL)
    }

    private func attemptCreationOfCoreDataStack() throws {
        NSLog("Confirming migrated database can be loaded at: \(storageSettings.sharedStorageURL)")
        try loadPersistentStorage(at: storageSettings.sharedStorageURL, journaling: true)
    }

    private func removeFailedMigrationFilesIfNeeded() {
        guard sharedStorageExists else {
            return
        }

        do {
            try fileManager.removeItem(at: storageSettings.sharedStorageURL)
        } catch {
            NSLog("Could not delete files from failed migration " + error.localizedDescription)
        }
    }

    private func backupLegacyDatabase() {
        do {
            try fileManager.moveItem(at: storageSettings.legacyStorageURL, to: storageSettings.legacyBackupURL)
        } catch {
            NSLog("Could not backup legacy storage database" + error.localizedDescription)
        }
    }
}

enum MigrationResult {
    case success
    case notNeeded
    case failed
}

private struct Constants {
    static let journalMode = "journal_mode"
    static let journalSetting = "DELETE"
    static let journalModeDisabled = [Constants.journalMode: Constants.journalSetting]
}
