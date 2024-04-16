import Foundation

// MARK: - NotesListSection
//
struct NotesListSection {

    /// Section Title
    ///
    let title: String?

    /// Section Objects
    ///
    let objects: [Any]

    /// Returns the number of Objects in the current section
    ///
    var numberOfObjects: Int {
        objects.count
    }

    var displaysTitle: Bool {
        title != nil && numberOfObjects > 0
    }
}
