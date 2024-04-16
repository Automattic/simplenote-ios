//
//  StoreProduct.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/26/22.
//  Copyright © 2022 Automattic. All rights reserved.
//

import Foundation

// MARK: - StoreProduct
//
enum StoreProduct: String, CaseIterable {
    case sustainerMonthly
    case sustainerYearly

    var identifier: String {
        switch self {
        case .sustainerYearly:
            return "com.codality.NotationalFlow.sustainer200"
        case .sustainerMonthly:
            return "com.codality.NotationalFlow.sustainer20"
        }
    }
}

extension StoreProduct {
    static var allIdentifiers: [String] {
        StoreProduct.allCases.map { product in
            product.identifier
        }
    }

    static func findStoreProduct(identifier: String) -> StoreProduct? {
        StoreProduct.allCases.first { storeProduct in
            storeProduct.identifier == identifier
        }
    }
}
