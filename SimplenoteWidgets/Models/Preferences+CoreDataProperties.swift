import Foundation
import CoreData


extension Preferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Preferences> {
        return NSFetchRequest<Preferences>(entityName: "Preferences")
    }

    @NSManaged public var analytics_enabled: NSNumber?
    @NSManaged public var ghostData: String?
    @NSManaged public var recent_searches: NSObject?
    @NSManaged public var simperiumKey: String?

}
