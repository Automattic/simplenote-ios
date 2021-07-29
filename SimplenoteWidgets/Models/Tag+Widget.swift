// This file contains the required class structure to be able to fetch and use core data files in widgets and intents
// We have collapsed the auto generated core data files into a single file as it is unlikely that the files will need to
// be regenerated.  Contained in this file is the generated class files Tag+CoreDataClass.swift and Tag+CoreDataProperties.swift

import Foundation
import CoreData

@objc(Tag)
public class Tag: SPManagedObject {

}

extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var index: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var share: String?
}
