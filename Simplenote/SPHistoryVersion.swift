import Foundation

// MARK: - SPHistoryVersion: Represents a version of an object
//
struct SPHistoryVersion {
    /// Version
    ///
    let version: Int

    /// Note's Payload
    ///
    let content: String

    /// Latest modification date
    ///
    let modificationDate: Date

    /// Designated Initializer
    ///
    init?(version: Int, payload: [AnyHashable: Any]) {
        guard let modification = payload[Keys.modificationDate.rawValue] as? Double,
            let content = payload[Keys.content.rawValue] as? String
            else {
                return nil
        }

        self.version = version
        self.modificationDate = Date(timeIntervalSince1970: TimeInterval(modification))
        self.content = content
    }
}

// MARK: - Parsing Keys
//
extension SPHistoryVersion {

    private enum Keys: String {
        case modificationDate
        case content
    }
}

// MARK: - SPHistoryVersion Hashable
//
extension SPHistoryVersion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }
}
