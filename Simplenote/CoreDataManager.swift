import Foundation
import CoreData
import AutomatticTracks

@objcMembers
class CoreDataManager: NSObject {

    /// Storage Settings
    ///
    private let storageSettings: StorageSettings

    @objc
    init(storageSettings: StorageSettings) {
        self.storageSettings = storageSettings
        super.init()
    }

    // MARK: Core Data
    private(set) lazy var managedObjectModel: NSManagedObjectModel = {
        guard let mom = NSManagedObjectModel(contentsOf: storageSettings.modelURL) else {
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

        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true, NSSQLitePragmasOption: [Constants.journalMode: Constants.journalSetting]] as [AnyHashable: Any]

        // Testing logs
        //
        NSLog("🎯 Loading PersistentStore at URL: \(storageSettings.storageURL)")

        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageSettings.storageURL, options: options)
        } catch {
            NSLog("Error loading PersistentStore at URL: \(storageSettings.storageURL)")
            CrashLogging.crash()
        }

        return psc
    }()
}

private struct Constants {
    static let journalMode = "journal_mode"
    static let journalSetting = "DELETE"
}
