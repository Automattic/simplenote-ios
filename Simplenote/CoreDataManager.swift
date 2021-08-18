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
        managedObjectModel = NSManagedObjectModel(contentsOf: storageSettings.modelURL)!
        managedObjectContext = buildMainContext()
        persistentStoreCoordinator = try buildStoreCoordinator(with: managedObjectModel, storageURL: storageURL)

        setupStackIfNeeded(mainContext: managedObjectContext, psc: persistentStoreCoordinator, for: usageType)
    }

    private func buildMainContext() -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.undoManager = nil
        return moc
    }

    private func buildStoreCoordinator(with model: NSManagedObjectModel, storageURL: URL) throws -> NSPersistentStoreCoordinator {
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
        return psc
    }

    private func setupStackIfNeeded(mainContext: NSManagedObjectContext, psc: NSPersistentStoreCoordinator, for usageType: CoreDataUsageType) {
        switch usageType {
        case .standard:
            break
        case .intents, .widgets:
            managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        }
    }
}
