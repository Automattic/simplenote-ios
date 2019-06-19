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
}


// MARK: - Dynamic Property
//
extension ActivityType {

    /// An account of the content of the description
    ///
    var description: String? {
        return nil
    }

    /// Date after which this activity is no longer eligible to be indexed or handed off
    ///
    var expirationDate: Date? {
        return .oneWeekFromNow
    }

    /// A human-understandable string that can be used to suggest a voice shortcut phrase to the user
    ///
    var suggestedInvocationPhrase: String {
        switch self {
        case .launch:
            return NSLocalizedString("Open Simplenote", comment: "Siri Suggestion to open our app")
        case .newNote:
            return NSLocalizedString("Create a New Note", comment: "Siri Suggestion to create a New Note")
        }
    }

    /// User-visible title for this activity
    ///
    var title: String {
        switch self {
        case .launch:
            return NSLocalizedString("Open Simplenote", comment: "Siri Suggestion to open our app")
        case .newNote:
            return NSLocalizedString("Create a New Note", comment: "Siri Suggestion to create a New Note")
        }
    }
}
