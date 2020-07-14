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
        noteEditorTextView.textContainerInset.left += Metrics.editorInsets.left
        noteEditorTextView.textContainerInset.right += Metrics.editorInsets.right
    }
}


// MARK: - Editor Metrics
//
private enum Metrics {
    static let editorInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
}
