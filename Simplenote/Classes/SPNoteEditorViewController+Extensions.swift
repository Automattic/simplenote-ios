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
        noteEditorTextView.textContainerInset.top += Metrics.editorInsetTop
    }
}


// MARK: - Editor Metrics
//
private enum Metrics {
    static let editorInsetTop = CGFloat(0.0)
}
