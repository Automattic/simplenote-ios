import Foundation

// MARK: - Simplenote's User Activities
//
enum ActivityType: String {

    /// Launch Simplenote Activity
    ///
    case launch = "com.codality.NotationalFlow.launch"

    /// New Note Activity
    ///
    case newNote = "com.codality.NotationalFlow.newNote"

    /// Open a Note!
    ///
    case openNote = "com.codality.NotationalFlow.openNote"

    /// Open an Item that was indexed by Spotlight
    ///
    case openSpotlightItem = "com.apple.corespotlightitem"
}
