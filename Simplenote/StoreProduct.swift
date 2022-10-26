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
    case sustainer

    var identifier: String {
        guard let prefix = Bundle.main.rootBundleIdentifier else {
            return "com.codality.NotationalFlow.sustainer"
        }

        return prefix + ".sustainer"
    }

    static var allIdentifiers: [String] {
        StoreProduct.allCases.map { product in
            product.identifier
        }
    }
}
