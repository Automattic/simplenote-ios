import Foundation


// MARK: - InterlinkManager
//
class InterlinkManager {

    /// Copies the Internal Link (Markdown Reference) into the OS Pasteboard
    ///
    @discardableResult
    func copyInternalLink(for note: Note) -> Bool {
        guard let title = note.titlePreview, let key = note.simperiumKey else {
            return false
        }

        UIPasteboard.general.string = markdownLink(title: title, key: key)

        return true
    }
}


// MARK: - Private API(s)
//
private extension InterlinkManager {

    func markdownLink(title: String, key: String) -> String {
        "[" + title + "](simplenote://" + key + ")"
    }
}
