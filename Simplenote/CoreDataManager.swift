import Foundation
import CoreData

enum CoreDataUsageType {
    case standard
    case intents
    case widgets
}

@objcMembers
class CoreDataManager: NSObject {

    // MARK: Core Data
    private(set) var managedObjectModel: NSManagedObjectModel!
    private(set) var managedObjectContext: NSManagedObjectContext!
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!

    init(_ storageURL: URL, storageSettings: StorageSettings = StorageSettings(), for usageType: CoreDataUsageType = .standard) throws {
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
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType,
                                       configurationName: nil,
                                       at: storageURL,
                                       options: options)
        } catch {
            throw StorageError.attachingPersistentStoreFailure
        }

        persistentStoreCoordinator = psc

        switch usageType {
        case .standard:
            break
        case .intents, .widgets:
            managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        }
    }
}
