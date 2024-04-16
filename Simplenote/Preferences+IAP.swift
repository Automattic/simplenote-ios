//
//  Preferences+IAP.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 10/27/22.
//  Copyright © 2022 Automattic. All rights reserved.
//

import Foundation

// MARK: - Preferences Extensions
//
extension Preferences {

    @objc
    var isActiveSubscriber: Bool {
        subscription_level == StoreConstants.activeSubscriptionLevel
    }

    @objc
    var wasSustainer: Bool {
        was_sustainer == true
    }
}
