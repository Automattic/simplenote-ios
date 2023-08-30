//
//  URLSessionConfiguration+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


// MARK: - URLSessionConfiguration Authentication
//
extension URLSessionConfiguration {

    static func dawnConfiguration() -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = dawnHeaders()
        return config
    }

    static func dawnHeaders() -> [AnyHashable: Any] {
        let headers = [
            "Accept": "vnd.day-one+json; version=2.0"
        ]

        return headers as [AnyHashable: Any]
    }
}
