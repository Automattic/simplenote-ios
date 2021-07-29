// This file contains the required class structure to be able to fetch and use core data files in widgets and intents
// We have collapsed the auto generated core data files into a single file as it is unlikely that the files will need to
// be regenerated.  Contained in this file is the generated class files SPManagedObject+CoreDataClass.swift and SPManagedObject+CoreDataProperties.swift

import Foundation
import CoreData

@objc(SPManagedObject)
public class SPManagedObject: NSManagedObject {

}

extension SPManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SPManagedObject> {
        return NSFetchRequest<SPManagedObject>(entityName: "SPManagedObject")
    }

    @NSManaged public var ghostData: String?
    @NSManaged public var simperiumKey: String?
}
