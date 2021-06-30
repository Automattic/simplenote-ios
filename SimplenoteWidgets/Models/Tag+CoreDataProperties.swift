//
//  Tag+CoreDataProperties.swift
//  
//
//  Created by Lantean on 6/30/21.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var index: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var share: String?

}
