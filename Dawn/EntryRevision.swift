//
//  EntryRevision.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation

// MARK: - Feed
//
struct EntryFeedEnvelope: Codable {
    let cursor: Int
    let contentLength: Int
    let encrypted: Bool
    let revision: EntryRevisionMetadata
}


// MARK: - Upload
//
enum EntryUploadOutcome: String, Codable {
    case clean
    case dirty
}

struct EntryUploadResponse: Codable {
    let outcome: EntryUploadOutcome
    let revision: EntryRevisionMetadata
}


// MARK: - Revision
//
enum RevisionType: String, Codable {
    case create, update, merge, delete
}

struct EntryRevision: Codable, Hashable {
    let metadata: EntryRevisionMetadata
    let payload: EntryRevisionPayload?
}

struct EntryRevisionMetadata: Codable, Hashable {
    var entryID: String
    var journalID: String
    var type: RevisionType
    var deviceID: String?
    var userID: String? = nil
    var editDate: Date?
    var saveDate: Date?
    var revisionID: Int?
    var revisionHistory: [Int]?
    var version: String?
    var entryDate: Date?
    var deletionRequested: Date?
    var purgeCompleted: Date?

    enum CodingKeys: String, CodingKey {
        case entryID = "entryId"
        case journalID = "journalId"
        case type
        case deviceID = "deviceId"
        case userID = "userId"
        case editDate
        case saveDate
        case revisionID = "revisionId"
        case revisionHistory
        case version
        case entryDate
        case deletionRequested
        case purgeCompleted
    }
}


struct EntryRevisionPayload: Codable, Hashable {
    var id: String
    var lastEditingDeviceID: String?
    var lastEditingDeviceName: String?
    var isPinned: Bool
    var tags: [String]
    var body: String
    var richTextJSON: String?

    var simplenoteBody: String {
        // setMissingAppleMediaIdentifiers: Why the Body has `\\` ?
        body.replacingOccurrences(of: "\\", with: "")
    }
}
