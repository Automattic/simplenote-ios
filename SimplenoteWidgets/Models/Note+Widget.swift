// This file contains the required class structure to be able to fetch and use core data files in widgets and intents
// We have collapsed the auto generated core data files into a single file as it is unlikely that the files will need to
// be regenerated.  Contained in this file is the generated class files Note+CoreDataClass.swift and Note+CoreDataProperties.swift

import Foundation
import CoreData

@objc(Note)
public class Note: SPManagedObject {

}

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

extension Note {
    private var lines: [String]? {
        content?.components(separatedBy: .newlines)
    }

    var title: String {
        guard let firstLine = lines?.first,
              firstLine.count > 0 else {
            return Constants.defaultTitle
        }
        return firstLine
    }

    var body: String {
        guard var lines = lines else {
            // Note. Swift UI Text will crash if given String() so need to use this version of an empty string
            return ""
        }
        lines.removeFirst()
        return lines.joined(separator: .newline)
    }

    var limitedTitle: String {
        String(title.prefix(Constants.previewCharacterLength))
    }

    var url: URL {
        guard let simperiumKey = simperiumKey else {
            return URL(string: SimplenoteConstants.simplenoteScheme + "://")!
        }
        return URL(string: Constants.linkUrlBase + simperiumKey)!
    }
}

private struct Constants {
    static let defaultTitle = NSLocalizedString("Untitled Note", comment: "Default title for notes")
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
    static let previewCharacterLength = 50
}
