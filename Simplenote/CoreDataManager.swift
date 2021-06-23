import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    /// URL for the managed object model resource
    ///
    static private let modelURL: URL = {
        Bundle.main.url(forResource: Constants.resourceName, withExtension: Constants.resourceType)!
    }()

    /// In app core data storage URL
    ///
    static let legacyStorageURL: URL = {
        FileManager.default.documentsURL.appendingPathComponent(Constants.sqlFile)
    }()

    /// URL for core data storage in shared app group documents directory
    ///
    static let groupStorageURL: URL = {
        FileManager.default.groupDocumentsDirectory.appendingPathComponent(Constants.sqlFile)
    }()

    var storageURL: URL {
        if SharedStorageMigrator.migrationNeeded {
            return CoreDataManager.legacyStorageURL
        }
        return CoreDataManager.groupStorageURL
    }

    // MARK: Core Data
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let mom = NSManagedObjectModel(contentsOf: CoreDataManager.modelURL) else {
            fatalError()
        }
        return mom
    }()

    private(set) lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.undoManager = nil
        return moc
    }()

    private(set) lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

        // Testing logs
        //
        NSLog("storage URL: \(storageURL)")

        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: options)
        } catch {
            NSLog("Unresolved Error")
        }

        return psc
    }()
}

private struct Constants {
    static let resourceName = "Simplenote"
    static let resourceType = "momd"
    static let sqlFile = "Simplenote.sqlite"
}
