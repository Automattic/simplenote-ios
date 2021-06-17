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

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: SPAppDelegate.shared().managedObjectModel)
        addPersistentStore(to: persistentStoreCoordinator, from: oldDbURL)

        // migrate DB if app group database doesn't exist
        print("Migrating Core Data store to app group directory")
        if let oldStore = persistentStoreCoordinator.persistentStore(for: oldDbURL) {
            do {
                try persistentStoreCoordinator.migratePersistentStore(oldStore, to: newDbURL, options: nil, withType: NSSQLiteStoreType)
                print("Migrate successful")
            } catch {
                print("Failed to migrate database from: \(oldDbURL) to \(newDbURL)")
                print(error.localizedDescription)
            }
        } else {
            print("Couldn't find data store")
        }
    }

    private static func addPersistentStore(to store: NSPersistentStoreCoordinator, from url: URL) {
        do {
            try store.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}

private struct Constants {
    static let defaultBundleIdentifier = "com.codality.NationalFlow"
    static let groupIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."
    static let sqlFile = "Simplenote.sqlite"
}
