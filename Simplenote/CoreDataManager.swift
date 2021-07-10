import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    init(_ storageURL: URL, storageSettings: StorageSettings = StorageSettings()) throws {
        super.init()

        try setupCoreDataStack(at: storageURL, modelURL: storageSettings.modelURL)
    }

    // MARK: Core Data
    private(set) var managedObjectModel: NSManagedObjectModel!
    private(set) var managedObjectContext: NSManagedObjectContext!
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    private func setupCoreDataStack(at url: URL, modelURL: URL) throws {
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Cannot load model")
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
