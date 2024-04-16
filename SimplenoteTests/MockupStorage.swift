import Foundation
import CoreData
@testable import Simplenote

/// MockupStorageManager: InMemory CoreData Stack.
///
class MockupStorageManager {

    /// DataModel Name
    ///
    private let name = "Simplenote"

    /// Returns the Storage associated with the View Thread.
    ///
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    /// Persistent Container: Holds the full CoreData Stack
    ///
    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: name, managedObjectModel: managedModel)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[MockupStorageManager] Fatal Error: \(error) [\(error.userInfo)]")
            }
        }

        return container
    }()

    /// Nukes the specified Object
    ///
    func delete(_ object: NSManagedObject) {
        viewContext.delete(object)
    }

    /// This method effectively destroys all of the stored data, and generates a blank Persistent Store from scratch.
    ///
    func reset() {
        let storeCoordinator = persistentContainer.persistentStoreCoordinator
        let storeDescriptor = self.storeDescription
        let viewContext = persistentContainer.viewContext

        viewContext.performAndWait {
            do {
                viewContext.reset()
                for store in storeCoordinator.persistentStores {
                    try storeCoordinator.remove(store)
                }
            } catch {
                fatalError("☠️ [MockupStorageManager] Cannot Destroy persistentStore! \(error)")
            }

            storeCoordinator.addPersistentStore(with: storeDescriptor) { (_, error) in
                guard let error = error else {
                    return
                }

                fatalError("☠️ [MockupStorageManager] Unable to regenerate Persistent Store! \(error)")
            }

            NSLog("💣 [MockupStorageManager] Stack Destroyed!")
        }
    }

    /// "Persists" the changes
    ///
    func save() {
        try? viewContext.save()
    }
}

// MARK: - Descriptors
//
extension MockupStorageManager {

    /// Returns the Application's ManagedObjectModel
    ///
    var managedModel: NSManagedObjectModel {
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("[MockupStorageManager] Could not load model")
        }

        return mom
    }

    /// Returns the PersistentStore Descriptor
    ///
    var storeDescription: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        return description
    }
}

// MARK: - Stack URL's
//
extension MockupStorageManager {

    /// Returns the ManagedObjectModel's URL: Pick this up from the Storage bundle. OKAY?
    ///
    var modelURL: URL {
        let bundle = Bundle(for: Note.self)
        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            fatalError("[MockupStorageManager] Missing Model Resource")
        }

        return url
    }
}
