import Foundation
import CoreData

class Note: NSManagedObject {
    @NSManaged var content: String
    @NSManaged var creationDate: Date
    @NSManaged override var isDeleted: Bool
    @NSManaged var lastPosition: Int32
    @NSManaged var modificationDate: Date
    @NSManaged var noteSynced: Bool
    @NSManaged var owner: String?
    @NSManaged var pinned: Bool
    @NSManaged var publishURL: String
    @NSManaged var remoteId: String?
    @NSManaged var shareURL: String
    @NSManaged var systemTags: String?
    @NSManaged var tags: String?
}

