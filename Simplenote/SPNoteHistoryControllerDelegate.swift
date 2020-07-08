import Foundation

// MARK: - SPNoteHistoryControllerDelegate
//
protocol SPNoteHistoryControllerDelegate: class {

    /// Cancel
    ///
    func noteHistoryControllerDidCancel()

    /// Finish and save
    ///
    func noteHistoryControllerDidFinish()

    /// Preview version content
    ///
    func noteHistoryControllerDidSelectVersion(with content: String)
}
