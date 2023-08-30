//
//  EntryRevision.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


struct EntryRevision {
    let envelope: EntryRevisionEnvelope
    let payload: EntryRevisionPayload

    var entryID: String {
        envelope.revision.entryID
    }

    var type: RevisionType {
        envelope.revision.type
    }

    var cursor: Int {
        envelope.cursor
    }

    var revisionID: Int? {
        envelope.revision.revisionID
    }

    var version: String? {
        envelope.revision.version
    }

    var deletionRequested: Date? {
        envelope.revision.deletionRequested
    }

    var purgeCompleted: Date? {
        envelope.revision.purgeCompleted
    }

    var lastEditingDeviceID: String {
        payload.lastEditingDeviceID
    }

    var lastEditingDeviceName: String {
        payload.lastEditingDeviceName
    }

    var isPinned: Bool {
        payload.isPinned
    }

    var tags: [String] {
        payload.tags
    }

    var body: String {
        payload.body
    }

    var richTextJSON: String? {
        payload.richTextJSON
    }
}


enum RevisionType: String, Codable {
    case create, update, merge, delete
}


struct EntryRevisionEnvelope: Decodable {
    let cursor: Int
    let contentLength: Int
    let encrypted: Bool
    let revision: EntryRevisionMetadata
}

struct EntryRevisionMetadata: Decodable {
    var entryID: String
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


struct EntryRevisionPayload: Decodable {
    var id: String
    var lastEditingDeviceID: String
    var lastEditingDeviceName: String
    var isPinned: Bool
    var tags: [String]
    var body: String
    var richTextJSON: String?
}
