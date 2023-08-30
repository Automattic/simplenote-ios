//
//  URLComponents+Dawn.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 30/08/2023.
//  Copyright © 2023 Automattic. All rights reserved.
//

import Foundation


extension URLComponents {
    public func queryValue(for name: String) -> String? {
        for item in self.queryItems ?? [] {
            if item.name == name {
                return item.value
            }
        }
        return nil
    }

    public mutating func setQueryItems(with dictionary: [String: Any]?) {
        guard let dictionary else {
            return
        }

        var queryItems: [URLQueryItem] = []
        for (key, value) in dictionary {
            switch value {
            case let array as Array<Any>:
                let arrayKey = key+"[]"
                let items = array.map({ URLQueryItem(name: arrayKey, value: String(describing: $0)) })
                queryItems += items

            default:
                let item = URLQueryItem(name: key, value: String(describing: value))
                queryItems.append(item)
            }
        }

        self.queryItems = queryItems
    }
}
