import Foundation

// MARK: - SPNoteHistoryControllerDelegate
//
protocol SPNoteHistoryControllerDelegate: AnyObject {

    /// Cancel
    ///
    func noteHistoryControllerDidCancel()

    /// Finish and save
    ///
    func noteHistoryControllerDidFinish()

    /// Preview version content
    ///
    func noteHistoryControllerDidSelectVersion(withContent content: String)
}
