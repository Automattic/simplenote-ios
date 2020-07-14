import Foundation


// MARK: - Editor Initialization
//
extension SPNoteEditorViewController {

    /// Initializes the Editor's TextView
    ///
    @objc
    func setupTextView() {
        noteEditorTextView = SPEditorTextView()
        noteEditorTextView.dataDetectorTypes = .all
        noteEditorTextView.font = .preferredFont(forTextStyle: .body)
        noteEditorTextView.checklistsFont = .preferredFont(forTextStyle: .headline)
    }
}
