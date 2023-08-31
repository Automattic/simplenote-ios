//
//  EntryEncoder.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 31/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


class EntryEncoder: MultipartEncoder {

    init?(metadata: EntryRevisionMetadata, payload: EntryRevisionPayload) {
        super.init()

        do {
            let encoder  = JSONEncoder.mercuryRecordEncoder
            let envelope = try encoder.encode(metadata)
            let content  = try encoder.encode(payload)

            addDataPart(envelope, name: "envelope", mimeType: "application/json")
            addDataPart(content, name: "content", mimeType: "application/json")

        } catch {
            NSLog("# Error Encoding: \(error)")
            return nil
        }
    }
}
