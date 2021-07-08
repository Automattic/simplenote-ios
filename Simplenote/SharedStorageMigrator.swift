import Foundation
import CoreData

@objc
class SharedStorageMigrator: NSObject {
    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup


    private var mustPerformMigration: Bool {
        FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path)
    }

    @objc
    func performMigrationIfNeeded() {
        // Confirm if the app group DB exists
        guard mustPerformMigration else {
            NSLog("Core Data Migration already complete")
            return
        }

        migrateCoreDataToAppGroup()
    }

    func migrateCoreDataToAppGroup() {
        // Testing prints
        // TODO: Remove prints later
        print("oldDb exists \(FileManager.default.fileExists(atPath: CoreDataManager.appStorageURL.path))")
        print(CoreDataManager.appStorageURL.path)
        print("newDb exists \(FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path))")
        print(CoreDataManager.groupStorageURL.path)

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: SPAppDelegate.shared().managedObjectModel)

        if FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path) {
            // Migration previously completed
            NSLog("Database migration not needed")

            // exit
            return
        }

        if !FileManager.default.fileExists(atPath: CoreDataManager.appStorageURL.path) && !FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path) {
            NSLog("New database needed")
            NSLog("Creating database in app group")

            // No DB exists
            // Create new DB in shared group
            createAppGroupDirectory(at: CoreDataManager.groupDocumentsDirectory)
            addPersistentStore(to: persistentStoreCoordinator, at: CoreDataManager.groupStorageURL)

            // Exit
            return
        }

        if FileManager.default.fileExists(atPath: CoreDataManager.appStorageURL.path) && !FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path) {
            // Old DB.  Needs Mirgation
            NSLog("Database needs migration to app group")
            NSLog("Beginning database migration")

            createAppGroupDirectory(at: CoreDataManager.groupDocumentsDirectory)

            // Option 1: Migrated old DB to new location
            migrateDatabase(from: CoreDataManager.appStorageURL, to: CoreDataManager.groupStorageURL, coordinator: persistentStoreCoordinator)

            // Option 2: Migrate old DB FILES to new location
//            migrateCoreDataFiles(from: documentsURL, to: groupDocumemntsDirectory)
        }
    }

    private func createAppGroupDirectory(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    @discardableResult private func addPersistentStore(to coordinator: NSPersistentStoreCoordinator, at url: URL) -> NSPersistentStore? {
        do {
            return try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private func migrateDatabase(from oldURL: URL, to newUrl: URL, coordinator: NSPersistentStoreCoordinator) {
        guard let store = addPersistentStore(to: coordinator, at: oldURL) else {
            NSLog("Could not get persistent store")
            NSLog("Database migration failed")
            return
        }

        do {
            try coordinator.migratePersistentStore(store, to: newUrl, options: nil, withType: NSSQLiteStoreType)
            NSLog("Migration Succeeded")
        } catch {
            // TODO: if migrating fails, confirm the directory exists at the new url.  If it does delete it or the app will load w/o data
            NSLog("Migration Failed")
            NSLog(error.localizedDescription)
        }
    }

    private func migrateCoreDataFiles(from oldUrl: URL, to newURL: URL) {
        let fileManager = FileManager.default

        // Testing prints
        // TODO: Remove prints later
        print(oldUrl)
        print(newURL)

        do {
            let files = try fileManager.contentsOfDirectory(atPath: oldUrl.path)
            try files.forEach { (file) in
                let oldPath = oldUrl.appendingPathComponent(file)
                let newPath = newURL.appendingPathComponent(file)
                try fileManager.copyItem(at: oldPath, to: newPath)
            }
        } catch {
            // TODO: if migration fails confirm the new dir is deleted
            NSLog("Could not migrate core data files")
            NSLog(error.localizedDescription)
        }
    }
}

private struct Constants {
    static let defaultBundleIdentifier = "com.codality.NationalFlow"
    static let groupIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."
    static let sqlFile = "Simplenote.sqlite"
    static let documentDirectory = "Documents"
}
