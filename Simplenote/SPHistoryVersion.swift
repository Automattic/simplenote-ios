import Foundation

// MARK: - SPHistoryVersion: Represents a version of an object
//
struct SPHistoryVersion {
    let version: Int
    let modificationDate: Date
    let content: String
}

// MARK: - SPHistoryVersion Hashable
//
extension SPHistoryVersion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }
}
