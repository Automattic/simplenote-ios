import Foundation
import CoreData

@objc
class SharedStorageMigrator: NSObject {
    /// Database Migration
    /// To be able to share data with app extensions, the CoreData database needs to be migrated to an app group
    /// Must run before Simperium is setup

    @objc
    func performMigrationIfNeeded() {
        // Confirm if the app group DB exists
        guard mustPerformMigration else {
            NSLog("Core Data Migration not required")
            return
        }

        migrateCoreDataToAppGroup()
    }

    private var mustPerformMigration: Bool {
        !CoreDataManager.appGroupDbExists && CoreDataManager.oldDbExists
    }


    func migrateCoreDataToAppGroup() {
        // Testing prints
        // TODO: Remove prints later
        print("oldDb exists \(FileManager.default.fileExists(atPath: CoreDataManager.appStorageURL.path))")
        print(CoreDataManager.appStorageURL.path)
        print("newDb exists \(FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path))")
        print(CoreDataManager.groupStorageURL.path)

        // Old DB.  Needs Mirgation
        NSLog("Database needs migration to app group")
        NSLog("Beginning database migration")

        // Option 2: Migrate old DB FILES to new location
        do {
            try migrateCoreDataStore(from: CoreDataManager.documentsDirectory, to: CoreDataManager.groupDocumentsDirectory)
            NSLog("Database migration successful!!")
        } catch {
            NSLog("Could not migrate database to app group")
            NSLog(error.localizedDescription)
        }
    }

    private func prepareNewDataBase(at newUrl: URL, storeCoordintator: NSPersistentStoreCoordinator) throws {
        try createAppGroupDirectory(at: newUrl)
        try addPersistentStore(to: storeCoordintator, at: newUrl)
    }

    private func createAppGroupDirectory(at url: URL) throws {
        do {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func addPersistentStore(to coordinator: NSPersistentStoreCoordinator, at url: URL) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    }

    private func migrateCoreDataStore(from oldURL: URL, to newURL: URL) throws {
        try createAppGroupDirectory(at: newURL)
        try migrateCoreDataFiles(from: oldURL, to: newURL)
    }

    private func migrateCoreDataFiles(from oldUrl: URL, to newURL: URL) throws {
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
