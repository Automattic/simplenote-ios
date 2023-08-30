//
//  Notification+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


public extension Notification {

    var managedObjectContext: NSManagedObjectContext? {
        self.object as? NSManagedObjectContext
    }

    var insertedManagedObjects: Set<NSManagedObject> {
        ((self as NSNotification).userInfo?[NSInsertedObjectsKey] ?? Set<NSManagedObject>()) as! Set<NSManagedObject>
    }

    var updatedManagedObjects: Set<NSManagedObject> {
        ((self as NSNotification).userInfo?[NSUpdatedObjectsKey] ?? Set<NSManagedObject>()) as! Set<NSManagedObject>
    }

    var refreshedManagedObjects: Set<NSManagedObject> {
        ((self as NSNotification).userInfo?[NSRefreshedObjectsKey] ?? Set<NSManagedObject>()) as! Set<NSManagedObject>
    }

    var deletedManagedObjects: Set<NSManagedObject> {
        ((self as NSNotification).userInfo?[NSDeletedObjectsKey] ?? Set<NSManagedObject>()) as! Set<NSManagedObject>
    }

    var managedObjects: Set<NSManagedObject> {
        var objects = self.insertedManagedObjects
        objects.formUnion(self.updatedManagedObjects)
        objects.formUnion(self.deletedManagedObjects)
        objects.formUnion(self.refreshedManagedObjects)

        return objects
    }

    func managedObjectsOfType<T: NSManagedObject>(_ type: T.Type) -> Set<T> {
        let objects = self.managedObjects
        return Set(objects.compactMap({ $0 as? T }))
    }

    func managedObjectsOfTypes(_ types: [NSManagedObject.Type]) -> Set<NSManagedObject> {
        let objects = self.managedObjects
        return Set(objects.filter { (obj) in
            types.contains(where: { obj.isKind(of: $0) })
        })
    }

    func containsManagedObjectsOfType<T: NSManagedObject>(_ type: T.Type) -> Bool {
        self.managedObjects.contains { object in
            object is T
        }
    }
}
