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
            return NSLocalizedString("Alphabetically: A-Z", comment: "Sort Mode: Alphabetically, ascending")
        case .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically: Z-A", comment: "Sort Mode: Alphabetically, descending")
        case .createdNewest:
            return NSLocalizedString("Created: Newest", comment: "Sort Mode: Creation Date, descending")
        case .createdOldest:
            return NSLocalizedString("Created: Oldest", comment: "Sort Mode: Creation Date, ascending")
        case .modifiedNewest:
            return NSLocalizedString("Modified: Newest", comment: "Sort Mode: Modified Date, descending")
        case .modifiedOldest:
            return NSLocalizedString("Modified: Oldest", comment: "Sort Mode: Modified Date, ascending")
        }
    }

    /// Returns the receiver's inverse order: Ascending > Descending, Newest > Oldest
    ///
    var inverse: SortMode {
        switch self {
        case .alphabeticallyAscending:
            return .alphabeticallyDescending
        case .alphabeticallyDescending:
            return .alphabeticallyAscending
        case .createdNewest:
            return .createdOldest
        case .createdOldest:
            return .createdNewest
        case .modifiedNewest:
            return .modifiedOldest
        case .modifiedOldest:
            return .modifiedNewest
        }
    }

    /// Returns a description describing the Mode (Family) Kind
    ///
    var kind: String {
        switch self {
        case .alphabeticallyAscending, .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically", comment: "Sort Mode: Alphabetically")
        case .createdNewest, .createdOldest:
            return NSLocalizedString("Created", comment: "Sort Mode: Creation Date")
        case .modifiedNewest, .modifiedOldest:
            return NSLocalizedString("Modified", comment: "Sort Mode: Modified Date")
        }
    }
}
