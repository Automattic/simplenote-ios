import Foundation

extension URL {
    static var newNoteURL: URL {
        URL(string: SimplenoteConstants.simplenoteScheme + "://new")!
    }
}
