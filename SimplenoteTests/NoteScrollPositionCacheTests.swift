import XCTest
@testable import Simplenote

// MARK: - NoteScrollPositionCacheTests
//
class NoteScrollPositionCacheTests: XCTestCase {
    private lazy var storage = MockFileStorage<NoteScrollPositionCache.ScrollCache>(fileURL: URL(fileURLWithPath: ""))
    private lazy var cache = NoteScrollPositionCache(storage: storage)

    func testPositionsAreInitiallyLoadedFromStorage() {
        // Given
        let key = UUID().uuidString
        let value = CGFloat.random(in: -99999..<99999)
        storage.data = [key: value]

        // Then
        XCTAssertEqual(cache.position(for: key), value)
    }

    func testPositionsAreSavedToStorage() {
        // Given
        let key = UUID().uuidString
        let value = CGFloat.random(in: -99999..<99999)

        // When
        cache.store(position: value, for: key)

        // Then
        XCTAssertEqual(cache.position(for: key), value)
        XCTAssertEqual(storage.data, [key: value])
    }

    func testOnlyProvidedKeysAreKeptDuringCleanup() {
        // Given
        let key1 = UUID().uuidString
        let value1 = CGFloat.random(in: -99999..<99999)

        let key2 = UUID().uuidString
        let value2 = CGFloat.random(in: -99999..<99999)

        cache.store(position: value1, for: key1)
        cache.store(position: value2, for: key2)

        // When
        cache.cleanup(keeping: [key1])

        // Then
        XCTAssertEqual(cache.position(for: key1), value1)
        XCTAssertNil(cache.position(for: key2))
    }
}

private class MockFileStorage<T: Codable>: FileStorage<T> {
    var data: T? = nil

    override func load() throws -> T? {
        return data
    }

    override func save(object: T) throws {
        data = object
    }
}
