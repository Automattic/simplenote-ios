import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    /// Storage Settings
    ///
    private let storageSettings: StorageSettings

    init(_ storageURL: URL, storageSettings: StorageSettings = StorageSettings()) throws {
        self.storageSettings = storageSettings
        super.init()

        try setupCoreDataStack(at: storageURL)
    }

    // MARK: Core Data
    private(set) var managedObjectModel: NSManagedObjectModel!
    private(set) var managedObjectContext: NSManagedObjectContext!
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    private func setupCoreDataStack(at url: URL) throws {
        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL) else {
            throw NSError(domain: "CoreDataManager", code: 100, userInfo: nil)
        }
        managedObjectModel = mom

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.undoManager = nil

        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        // Testing logs
        //
        NSLog("🎯 Loading PersistentStore at URL: \(url)")
        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                       configurationName: nil,
                                       at: url,
                                       options: options)

        persistentStoreCoordinator = psc
    }
}
