//
//  SortMode.swift
//  Simplenote
//
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation


// MARK: - Represents all of the possible Sort Modes
//
@objc
enum SortMode: Int, CaseIterable {

    /// Order: A-Z
    ///
    case alphabeticallyAscending

    /// Order: Z-A
    ///
    case alphabeticallyDescending

    /// Order: Newest on Top
    ///
    case createdNewest

    /// Order: Oldest on Top
    ///
    case createdOldest

    /// Order: Newest on Top
    ///
    case modifiedNewest

    /// Order: Oldest on Top
    ///
    case modifiedOldest

    /// Returns a localized Description, matching the current rawValue
    ///
    var description: String {
        switch self {
        case .alphabeticallyAscending:
            return NSLocalizedString("Alphabetically: A-Z", comment: "")
        case .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically: Z-A", comment: "")
        case .createdNewest:
            return NSLocalizedString("Created: Newest", comment: "")
        case .createdOldest:
            return NSLocalizedString("Created: Oldest", comment: "")
        case .modifiedNewest:
            return NSLocalizedString("Modified: Newest", comment: "")
        case .modifiedOldest:
            return NSLocalizedString("Modified: Oldest", comment: "")
        }
    }
}
