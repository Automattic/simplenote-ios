import Foundation

// MARK: - NoteMetrics
//
struct NoteMetrics {

    /// Returns the total number of characters
    ///
    let numberOfChars: Int

    /// Returns the total number of words
    ///
    let numberOfWords: Int

    /// Creation Date
    ///
    let creationDate: Date

    /// Modification Date
    ///
    let modifiedDate: Date

    /// Designed Initializer
    /// - Parameter note: Note from which we should extract metrics
    ///
    init(note: Note) {
        let content = ((note.content ?? "") as NSString)

        numberOfChars = content.charCount
        numberOfWords = content.wordCount
        creationDate = note.creationDate
        modifiedDate = note.modificationDate
    }
}
