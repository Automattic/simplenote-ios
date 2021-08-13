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
        guard let content = content else {
            return nil
        }

        return content.components(separatedBy: .newlines)
    }

    private var firstLine: String {
        guard let lines = lines else {
            return Constants.defaultTitle
        }
        return lines.first ?? String()
    }

    var title: String {
        return firstLine.count > .zero ? firstLine : Constants.defaultTitle
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
        guard firstLine.count > .zero else {
            return Constants.defaultTitle
        }
        return String(firstLine.prefix(50))
    }

    var url: URL {
        guard let simperiumKey = simperiumKey else {
            return URL(string: SimplenoteConstants.simplenoteScheme + "://")!
        }
        return URL(string: WidgetConstants.interlinkURLBase + simperiumKey)!
    }
}

private struct Constants {
    static let defaultTitle = NSLocalizedString("Untitled Note", comment: "Default title for notes")
}
