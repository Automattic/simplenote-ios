import Foundation

// MARK: - SPHistoryVersion: Represents a version of an object
//
struct SPHistoryVersion {
    let version: Int
    let modificationDate: Date
    let content: String
}

// MARK: - SPHistoryVersion: Init with raw data
//
extension SPHistoryVersion {
    init(version: Int, data: [String: Any]) {
        self.version = version

        let timeInterval = data["modificationDate"] as? TimeInterval
        modificationDate = Date(timeIntervalSince1970: timeInterval ?? 0)
        content = (data["content"] as? String) ?? ""
    }
}

// MARK: - SPHistoryVersion Hashable
//
extension SPHistoryVersion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }
}
