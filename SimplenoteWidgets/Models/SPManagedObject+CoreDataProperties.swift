//
//  SPManagedObject+CoreDataProperties.swift
//  
//
//  Created by Lantean on 6/30/21.
//
//

import Foundation
import CoreData


extension SPManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SPManagedObject> {
        return NSFetchRequest<SPManagedObject>(entityName: "SPManagedObject")
    }

    @NSManaged public var ghostData: String?
    @NSManaged public var simperiumKey: String?

}
