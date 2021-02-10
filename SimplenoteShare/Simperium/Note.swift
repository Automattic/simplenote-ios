import Foundation


/// This class encapsulates the Note entity. It's the main project (non core data) counterpart.
///
class Note {

    /// Note's Simperium Unique Key
    ///
    let simperiumKey: String = {
        return UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }()

    /// Payload
    ///
    let content: String

    /// Indicates if the Note is a Markdown document
    ///
    let markdown: Bool

    /// Creation Date: Now, by default!
    ///
    let creationDate = Date()

    /// Last Modification Date: Now, by default!
    ///
    let modificationDate = Date()


    /// Designated Initializer
    ///
    init(content: String, markdown: Bool = false) {
        self.content = content
        self.markdown = markdown
    }

    func toDictionary() -> [String: Any] {
        var systemTags = [String]()
        if markdown {
            systemTags.append("markdown")
        }

        return [
            "tags": [],
            "deleted": 0,
            "shareURL": String(),
            "publishURL": String(),
            "content": content,
            "systemTags": systemTags,
            "creationDate": creationDate.timeIntervalSince1970,
            "modificationDate": modificationDate.timeIntervalSince1970
        ]
    }

    func toJsonData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: toDictionary(), options: .prettyPrinted)
        } catch {
            print("Error converting Note to JSON: \(error)")
            return nil
        }
    }
}
