//
//  Simperium.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import UIKit
import CoreData

@objc
protocol SPBucketDelegate {

}

@objc
protocol SimperiumDelegate {

}

@objcMembers
class SPBucket: NSObject {

    var notifyWhileIndexing = false
    var delegate: SPBucketDelegate?

    func object(forKey key: String) -> Any? {
        nil
    }

    func requestVersions(_ count: Int, key: String) {

    }

    func allObjects() -> [Any] {
        []
    }

    func insertNewObjectForKey(_ key: String) -> Any? {
        nil
    }
}


@objcMembers
class SPUser: NSObject {
    var email = ""
    var authToken = ""
    var delegate: SPBucketDelegate?

    func authenticated() -> Bool {
        false
    }

    init(email: String, token: String) {

    }
}


@objcMembers
class SPKeychain: NSObject {
    class func setPassword(_ password: String, forService service: String, account: String) throws {

    }

    class func deletePasswordForService(_ service: String, account: String) {

    }
}

@objcMembers
class SPAuthenticator: NSObject {

    var providerString = ""
    var connected = true

    func authenticate(withUsername email: String, token: String) {

    }

    func authenticate(withUsername: String,
                      password: String,
                      success: () -> Void,
                      failure: (Int, String, NSError) -> Void) {

    }

    func validate(withUsername: String,
                  password: String,
                  success: () -> Void,
                  failure: (Int, String, NSError) -> Void) {

    }
}

@objc
enum SPSimperiumErrors: Int {
    case invalidToken
}

@objc
enum SPBucketChangeType: Int {
    case update
    case insert
    case delete
}


@objc
protocol SPAuthenticationInterface {

    var authenticator: SPAuthenticator? { get set }
//    var optional: Bool { get set }
//    var signingIn: Bool { get set }
}


@objcMembers
public class Simperium: NSObject {

    var verboseLoggingEnabled = false

    var user: SPUser?

    var delegate: SimperiumDelegate?

    var authenticator = SPAuthenticator()
    var authenticationViewControllerClass: Any?
    var authenticationShouldBeEmbeddedInNavigationController = false

    var requiresConnection = false
    var managedObjectContext: NSManagedObjectContext
    var writerObjectContext: NSManagedObjectContext

    var networkStatus = ""

    init(model: NSManagedObjectModel, context: NSManagedObjectContext, coordinator: NSPersistentStoreCoordinator) {
        managedObjectContext = context

        writerObjectContext = {
            let writerContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            writerContext.persistentStoreCoordinator = coordinator
            return writerContext
        }()

        managedObjectContext.parent = writerObjectContext
        managedObjectContext.automaticallyMergesChangesFromParent = true
    }

    var networkLastSeenTime: Date {
        Date()
    }

    func preferencesObject() -> Preferences {
        let request = NSFetchRequest<Preferences>(entityName: "Preferences")
        request.predicate = NSPredicate(format: "%K = %@", #keyPath(Note.simperiumKey), kSimperiumPreferencesObjectKey)

        if let preferences = try? managedObjectContext.fetch(request).first {
            return preferences
        }

        let preferences = Preferences(context: managedObjectContext)
        preferences.simperiumKey = kSimperiumPreferencesObjectKey
        return preferences
    }

    func bucket(forName name: String) -> SPBucket? {
        SPBucket()
    }

    func authenticateIfNecessary() {

    }

    func save() {
        guard #available(iOS 15.0, *) else {
            return
        }

        do {
            try managedObjectContext.save()
            try writerObjectContext.performAndWait {
                try writerObjectContext.save()
            }
        } catch {
            NSLog("Save Error: \(error)")
        }
    }

    func saveWithoutSyncing() {
        save()
    }

    func signOutAndRemoveLocalData(_ remove: Bool, completion: () -> Void) {

    }

    func authenticateWithAppID(_ appID: String, APIKey: String, rootViewController: UIViewController) {

    }

    func authenticationDidSucceedForUsername(_ username: String, token: String) {

    }
}


extension UIDevice {
    class func sp_isPad() -> Bool {
        false
    }
}
