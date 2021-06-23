import Foundation
import CoreData

@objcMembers
class CoreDataManager: NSObject {

    /// URL for the managed object model resource
    ///
    static private let modelURL: URL? = {
        guard let path = Bundle.main.path(forResource: Constants.resourceName, ofType: Constants.resourceType) else {
            return nil
        }
        return URL(string: path)
    }()

    /// URL for the in app documents directory
    ///
    static let documentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()

    /// In app core data storge URL
    ///
    static let appStorageURL: URL = {
        documentsDirectory.appendingPathComponent(Constants.sqlFile)
    }()

    /// URL for Simplenote's shared app group directory
    ///
    static let groupDirectory: URL = {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.sharedDirectoryDomain + Constants.groupIdentifier)!
    }()

    /// URL for Simplenote's shared app group documents directory
    ///
    static let groupDocumentsDirectory: URL = {
        groupDirectory.appendingPathComponent(Constants.documentDirectory)
    }()

    /// URL for core data storage in shared app group documents directory
    ///
    static let groupStorageURL: URL = {
        groupDocumentsDirectory.appendingPathComponent(Constants.sqlFile)
    }()

    /// Bool checking if the in app database exsists
    ///
    static let oldDbExists: Bool = {
        FileManager.default.fileExists(atPath: CoreDataManager.appStorageURL.path)
    }()

    /// Bool checking if the app group database exsists
    ///
    static let appGroupDbExists: Bool = {
        FileManager.default.fileExists(atPath: CoreDataManager.groupStorageURL.path)
    }()

    // MARK: Core Data
    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = CoreDataManager.modelURL,
              let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError()
        }
        return mom
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.undoManager = nil
        return moc
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let psc = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

        var storeURL: URL = CoreDataManager.appGroupDbExists ? CoreDataManager.groupStorageURL : CoreDataManager.appStorageURL
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]

        // Testing logs
        //
        NSLog("storage URL: \(storeURL)")

        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            NSLog("Unresolved Error")
        }

        return psc
    }()
}

private struct Constants {
    static let resourceName = "Simplenote"
    static let resourceType = "momd"
    static let defaultBundleIdentifier = "com.codality.NationalFlow"
    static let groupIdentifier = Bundle.main.bundleIdentifier ?? Constants.defaultBundleIdentifier
    static let sharedDirectoryDomain = "group."
    static let sqlFile = "Simplenote.sqlite"
    static let documentDirectory = "Documents"
}
