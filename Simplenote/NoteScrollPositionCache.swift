import Foundation

// MARK: - NoteScrollPositionCache: cache scroll offset and cursor position
//
final class NoteScrollPositionCache {
    private var cache: [String: CGFloat] = [:]

    /// Returns cached scroll position
    ///
    func position(for key: String) -> CGFloat? {
        return cache[key]
    }

    /// Stores scroll position
    ///
    func store(position: CGFloat, for key: String) {
        cache[key] = position
    }
}
