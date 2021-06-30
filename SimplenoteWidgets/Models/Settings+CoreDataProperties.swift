//
//  Settings+CoreDataProperties.swift
//  
//
//  Created by Lantean on 6/30/21.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var decline_skip_versions: NSNumber?
    @NSManaged public var dislike_skip_versions: NSNumber?
    @NSManaged public var ghostData: String?
    @NSManaged public var like_skip_versions: NSNumber?
    @NSManaged public var minimum_events: NSNumber?
    @NSManaged public var minimum_interval_days: NSNumber?
    @NSManaged public var ratings_disabled: NSNumber?
    @NSManaged public var simperiumKey: String?

}
