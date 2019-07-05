import Foundation


// MARK: - UIActivityItem With Special Treatment for WordPress iOS
//
class SimplenoteActivityItemSource: NSObject, UIActivityItemSource {

    /// The Note that's about to be exported
    ///
    private let note: Note

    /// Designated Initializer
    ///
    init(note: Note) {
        self.note = note
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return note.content ?? String()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard activityType?.isWordPressActivity == true else {
            return note.content
        }

        return FileManager.writeToDocuments(note: note) ?? note.content
    }
}
