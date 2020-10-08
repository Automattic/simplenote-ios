import Foundation


// MARK: - UIPasteboard + Interlink
//
extension UIPasteboard {

    /// Copies the Internal Link (Markdown Reference) into the OS Pasteboard
    ///
    func copyInterlink(to note: Note) {
        guard let link = note.markdownInternalLink else {
            return
        }

        string = link
    }
}
