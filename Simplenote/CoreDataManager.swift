import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    // MARK: Core Data
    private(set) var managedObjectModel: NSManagedObjectModel!
    private(set) var managedObjectContext: NSManagedObjectContext!
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    init(_ storageURL: URL, storageSettings: StorageSettings = StorageSettings()) throws {
        super.init()

        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL) else {
            fatalError("Cannot load model")
        }
        managedObjectModel = mom

        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.undoManager = nil

        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]

        NSLog("🎯 Loading PersistentStore at URL: \(storageURL)")
        try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                       configurationName: nil,
                                       at: storageURL,
                                       options: options)

        persistentStoreCoordinator = psc
    }
}
