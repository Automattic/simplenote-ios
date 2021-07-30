import Foundation

class WidgetDataController {
    let coreDataManager: CoreDataManager

    let 

    init() throws {
        // TODO: Check if main app is logged in, if not throw

        self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL)

    }
}
