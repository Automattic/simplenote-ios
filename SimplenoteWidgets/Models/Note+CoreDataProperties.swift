import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var content: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public override var isDeleted: Bool
    @NSManaged public var lastPosition: NSNumber?
    @NSManaged public var modificationDate: Date?
    @NSManaged public var noteSynced: NSNumber?
    @NSManaged public var owner: String?
    @NSManaged public var pinned: NSNumber?
    @NSManaged public var publishURL: String?
    @NSManaged public var remoteId: String?
    @NSManaged public var shareURL: String?
    @NSManaged public var systemTags: String?
    @NSManaged public var tags: String?

}
