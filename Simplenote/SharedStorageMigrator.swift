import Foundation
import CoreData

class SharedStorageMigrator {

    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup
    @objc
    static func migrateCoreDataToAppGroup() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
              let groupDocumemntsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier) else {
            return
        }
        let oldDbURL = documentsURL.appendingPathComponent(Constants.sqlFile)
        let newDbURL = groupDocumemntsDirectory.appendingPathComponent(Constants.sqlFile)

        // Testing prints
        // TODO: Remove prints later
        print("oldDb exists \(FileManager.default.fileExists(atPath: oldDbURL.path))")
        print("newDb exists \(FileManager.default.fileExists(atPath: newDbURL.path))")

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: SPAppDelegate.shared().managedObjectModel)

        if FileManager.default.fileExists(atPath: newDbURL.path) {
            // Migration previously completed
            NSLog("Database migration not needed")

            // exit
            return
        }

        if !FileManager.default.fileExists(atPath: oldDbURL.path) && !FileManager.default.fileExists(atPath: newDbURL.path) {
            NSLog("New database needed")
            NSLog("Creating database in app group")

            // No DB exists
            // Create new DB in shared group
            addPersistentStore(to: persistentStoreCoordinator, at: newDbURL)

            // Exit
            return
        }

        if FileManager.default.fileExists(atPath: oldDbURL.path) && !FileManager.default.fileExists(atPath: newDbURL.path) {
            // Old DB.  Needs Mirgation
            NSLog("Database needs migration to app group")
            NSLog("Beginning database migration")

            // Migrated old DB to new location
            migrateDatabase(from: oldDbURL, to: newDbURL, coordinator: persistentStoreCoordinator)
        }
    }

    @discardableResult private static func addPersistentStore(to coordinator: NSPersistentStoreCoordinator, at url: URL) -> NSPersistentStore? {
        do {
            return try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    private static func migrateDatabase(from oldURL: URL, to newUrl: URL, coordinator: NSPersistentStoreCoordinator) {
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

    private func migrateCoreDataFiles(from url: URL, to newURL: URL) {
        let fileManager = FileManager.default

        do {
            let files = try fileManager.contentsOfDirectory(atPath: url.path)
            try files.forEach { (file) in
                let oldPath = url.appendingPathComponent(file)
                let newPath = newURL.appendingPathComponent(file)
                try fileManager.moveItem(at: oldPath, to: newPath)
            }
        } catch {
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
}
