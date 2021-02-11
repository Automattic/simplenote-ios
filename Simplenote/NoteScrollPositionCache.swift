import Foundation

// MARK: - NoteScrollPositionCache: cache scroll offset
//
final class NoteScrollPositionCache {
    typealias ScrollCache = [String: CGFloat]

    private var cache: ScrollCache {
        didSet {
            try? storage.save(object: cache)
        }
    }

    private let storage: FileStorage<ScrollCache>

    init(storage: FileStorage<ScrollCache>) {
        self.storage = storage

        let storedCache = try? storage.load()
        cache = storedCache ?? [:]
    }

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

    /// Cleanup
    ///
    func cleanup(keeping keys: [String]) {
        cache = cache.filter({ keys.contains($0.key) })
    }
}
