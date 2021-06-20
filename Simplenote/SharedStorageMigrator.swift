import Foundation
import CoreData

class SharedStorageMigrator {

    static let documentsURL: URL? = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    static let groupDirectory: URL? = {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier)
    }()

    static let groupDocumentsDirectory: URL? = {
        guard let groupDirectory = groupDirectory else {
            return nil
        }
        return groupDirectory.appendingPathComponent(Constants.documentDirectory)
    }()

    static let oldDbURL: URL? = {
        guard let documentsURL = documentsURL else {
            return nil
        }

        return documentsURL.appendingPathComponent(Constants.sqlFile)
    }()

    static let newDbURL: URL? = {
        guard let groupDocumentsDirectory = groupDocumentsDirectory else {
            return nil
        }
        return groupDocumentsDirectory.appendingPathComponent(Constants.sqlFile)
    }()

    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup
    static func migrateCoreDataToAppGroup() {
        guard let oldDbURL = oldDbURL,
              let groupDocumentsDirectory = groupDocumentsDirectory,
              let newDbURL = newDbURL else {
            return
        }

        // Testing prints
        // TODO: Remove prints later
        print("oldDb exists \(FileManager.default.fileExists(atPath: oldDbURL.path))")
        print(oldDbURL.path)
        print("newDb exists \(FileManager.default.fileExists(atPath: newDbURL.path))")
        print(newDbURL.path)

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
            createAppGroupDirectory(at: groupDocumentsDirectory)
            addPersistentStore(to: persistentStoreCoordinator, at: newDbURL)

            // Exit
            return
        }

        if FileManager.default.fileExists(atPath: oldDbURL.path) && !FileManager.default.fileExists(atPath: newDbURL.path) {
            // Old DB.  Needs Mirgation
            NSLog("Database needs migration to app group")
            NSLog("Beginning database migration")

            createAppGroupDirectory(at: groupDocumentsDirectory)

            // Option 1: Migrated old DB to new location
            migrateDatabase(from: oldDbURL, to: newDbURL, coordinator: persistentStoreCoordinator)

            // Option 2: Migrate old DB FILES to new location
//            migrateCoreDataFiles(from: documentsURL, to: groupDocumemntsDirectory)
        }
    }

    private static func createAppGroupDirectory(at url: URL) {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
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

    private static func migrateCoreDataFiles(from oldUrl: URL, to newURL: URL) {
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
