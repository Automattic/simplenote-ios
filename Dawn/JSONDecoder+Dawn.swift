//
//  JSONDecoder+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


extension JSONEncoder {
    public static var mercuryRecordEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ (date, encoder) throws -> Void in
            let milliseconds = date.timeIntervalSince1970 * 1000
            let roundedMilliseconds = Int64(milliseconds)
            var container = encoder.singleValueContainer()
            try container.encode(roundedMilliseconds)
        })
        return encoder
    }()
}


extension JSONDecoder {
    public static var mercuryRecordDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }

    static var chocolateRecordDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601WithZFormatter)
        return decoder
    }
}
