//
//  UIAlertController+Sustainer.swift
//  Simplenote
//
//  Created by Jorge Leandro Perez on 11/8/22.
//  Copyright © 2022 Automattic. All rights reserved.
//

import Foundation


// MARK: - UIAlertController+Sustainer
//
@available(iOS 15, *)
extension UIAlertController {

    static func buildSustainerAlert() -> UIAlertController {
        let manager = StoreManager.shared
        let monthlyActionTitle = Localization.monthlyActionTitle(price: manager.displayPrice(for: .sustainerMonthly))
        let yearlyActionTitle = Localization.yearlyActionTitle(price: manager.displayPrice(for: .sustainerYearly))

        let alert = UIAlertController(title: Localization.title, message: Localization.message, preferredStyle: .actionSheet)
        alert.addActionWithTitle(monthlyActionTitle, style: .default) { _ in
            SPTracker.trackSustainerMonthlyButtonTapped()
            manager.purchase(storeProduct: .sustainerMonthly)
        }

        alert.addActionWithTitle(yearlyActionTitle, style: .default) { _ in
            SPTracker.trackSustainerYearlyButtonTapped()
            manager.purchase(storeProduct: .sustainerYearly)
        }

        alert.addCancelActionWithTitle(Localization.dismissActionTitle) { _ in
            SPTracker.trackSustainerDismissButtonTapped()
        }

        return alert
    }
}


// MARK: - Localization
//
private enum Localization {
    static let title = NSLocalizedString("Simplenote Sustainer", comment: "Sustainer Alert's Title")
    static let message = NSLocalizedString("Choose a plan and help unlock future features", comment: "Sustainer Alert's Message")
    static let dismissActionTitle = NSLocalizedString("Cancel", comment: "Dismisses the alert")

    static func monthlyActionTitle(price: String?) -> String {
        guard let price else {
            return NSLocalizedString("Monthly", comment: "Monthly Subscription Option (Used when / if the price fails to load)")
        }

        let text = NSLocalizedString("%@ per Month", comment: "Monthly Subscription Option. Please preserve the special marker!")
        return String(format: text, price)
    }

    static func yearlyActionTitle(price: String?) -> String {
        guard let price else {
            return NSLocalizedString("Yearly", comment: "Yearly Subscription Option (Used when / if the price fails to load)")
        }

        let text = NSLocalizedString("%@ per Year", comment: "Yearly Subscription Option. Please preserve the special marker!")
        return String(format: text, price)
    }
}
