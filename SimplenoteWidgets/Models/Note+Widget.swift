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
    var title: String {
        let (titleRange, _) = NoteContentHelper.structure(of: content)
        return title(with: titleRange)
    }

    private func title(with range: Range<String.Index>?) -> String {
        guard let range = range, let content = content else {
            return Constants.defaultTitle
        }

        let result = String(content[range])
        return result.droppingPrefix(Constants.titleMarkdownPrefix)
    }

    var body: String {
        let (_, bodyRange) = NoteContentHelper.structure(of: content)
        return body(with: bodyRange)
    }

    private func body(with range: Range<String.Index>?) -> String {
        guard let range = range, let content = content else {
            // Note. Swift UI Text will crash if given String() so need to use this version of an empty string
            return ""
        }

        let upperBound = content.index(range.lowerBound, offsetBy: Constants.bodyPreviewCap, limitedBy: range.upperBound) ?? range.upperBound
        let cappedRange = range.lowerBound..<upperBound

        return String(content[cappedRange])
    }

    var url: URL {
        guard let simperiumKey = simperiumKey else {
            return URL(string: .simplenotePath())!
        }
        return URL(string: .simplenotePath(withHost: SimplenoteConstants.simplenoteInterlinkHost) + simperiumKey)!
    }
}

private struct Constants {
    static let defaultTitle = NSLocalizedString("New Note...", comment: "Default title for notes")
    static let previewCharacterLength = 50
    static let titleMarkdownPrefix = "# "
    static let bodyPreviewCap = 500
}
