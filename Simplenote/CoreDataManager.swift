import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    /// URL for the managed object model resource
    ///
    static private let modelURL: URL = {
        Bundle.main.url(forResource: Constants.resourceName, withExtension: Constants.resourceType)!
    }()

    /// Storage Settings
    ///
    let storageSettings: StorageSettings

    @objc
    init(storageSettings: StorageSettings) {
        self.storageSettings = storageSettings
        super.init()
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
        NSLog("🎯 Loading PersistentStore at URL: \(storageSettings.storageURL)")

        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageSettings.storageURL, options: options)
        } catch {
            NSLog("Unresolved Error")
        }

        return psc
    }()
}

private struct Constants {
    static let resourceName = "Simplenote"
    static let resourceType = "momd"
}
