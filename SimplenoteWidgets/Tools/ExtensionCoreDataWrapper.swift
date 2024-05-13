import Foundation
import CoreData

class ExtensionCoreDataWrapper {
    private lazy var coreDataManager: CoreDataManager = {
        do {
            return try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
        } catch {
            fatalError()
        }
    }()

    private lazy var extensionResultsController: ExtensionResultsController = {
        ExtensionResultsController(context: coreDataManager.managedObjectContext)
    }()

    func resultsController() -> ExtensionResultsController? {
        guard FileManager.default.fileExists(atPath: StorageSettings().sharedStorageURL.path) else {
            return nil
        }
        return extensionResultsController
    }

    func context() -> NSManagedObjectContext {
        coreDataManager.managedObjectContext
    }
}
