import Foundation


/// This class encapsulates the Note entity. It's the main project (non core data) counterpart.
///
class Note {

    /// Note's Simperium Unique Key
    ///
    let simperiumKey: String

    /// Payload
    ///
    let content: String

    /// Creation Date: Now, by default!
    ///
    let creationDate = Date()

    /// Last Modification Date: Now, by default!
    ///
    let modificationDate = Date()


    /// Designated Initializer
    ///
    init(content: String) {
        self.content = content
        self.simperiumKey = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    }

    func toDictionary() -> [String: Any] {
        return [
            "tags"              : [],
            "deleted"           : 0,
            "shareURL"          : String(),
            "publishURL"        : String(),
            "content"           : content,
            "systemTags"        : [],
            "creationDate"      : creationDate.timeIntervalSince1970,
            "modificationDate"  : modificationDate.timeIntervalSince1970
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
