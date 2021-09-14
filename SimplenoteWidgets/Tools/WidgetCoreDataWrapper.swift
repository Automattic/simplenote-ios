import Foundation

class WidgetCoreDataWrapper {
    private lazy var coreDataManager: CoreDataManager = {
        do {
            return try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
        } catch {
            fatalError()
        }
    }()

    private lazy var widgetResultsController: WidgetResultsController = {
        WidgetResultsController(context: coreDataManager.managedObjectContext)
    }()

    func resultsController() -> WidgetResultsController? {
        guard FileManager.default.fileExists(atPath: StorageSettings().sharedStorageURL.path) else {
            return nil
        }
        return widgetResultsController
    }
}
