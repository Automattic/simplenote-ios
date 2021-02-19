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
            return NSLocalizedString("Name: A-Z", comment: "Sort Mode: Alphabetically, ascending")
        case .alphabeticallyDescending:
            return NSLocalizedString("Name: Z-A", comment: "Sort Mode: Alphabetically, descending")
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
}
