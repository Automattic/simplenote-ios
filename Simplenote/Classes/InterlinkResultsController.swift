import Foundation
import SimplenoteFoundation

// MARK: - InterlinkResultsController
//
class InterlinkResultsController {

    /// ResultsController: In charge of CoreData Queries!
    ///
    private let resultsController: ResultsController<Note>

    /// Limits the maximum number of results to fetch
    ///
    var maximumNumberOfResults = Settings.defaultMaximumResults

    /// Designated Initializer
    ///
    init(viewContext: NSManagedObjectContext) {
        resultsController = ResultsController<Note>(viewContext: viewContext, sortedBy: [
            NSSortDescriptor(keyPath: \Note.content, ascending: true)
        ])

        resultsController.predicate = NSPredicate.predicateForNotes(deleted: false)
        try? resultsController.performFetch()
    }

    /// Returns the collection of Notes filtered by the specified Keyword in their title, excluding a specific ObjectID
    /// - Important: Returns `nil` when there are no results!
    ///
    func searchNotes(byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?) -> [Note]? {
        filter(notes: resultsController.fetchedObjects, byTitleKeyword: keyword, excluding: excludedID)
    }
}

// MARK: - Private
//
private extension InterlinkResultsController {

    /// Filters a collection of notes by their Title contents, excluding a specific Object ID.
    ///
    /// - Important: Why do we perform an *in memory* filtering?
    ///     - CoreData's SQLite store does not support block based predicates
    ///     - RegExes aren't diacritic + case insensitve friendly
    ///     - It's easier and anyone can follow along!
    ///
    func filter(notes: [Note], byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?) -> [Note]? {
        let comparisonOptions: NSString.CompareOptions = [.diacriticInsensitive, .caseInsensitive]
        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        var output = [Note]()

        for note in notes where note.objectID != excludedID {
            note.ensurePreviewStringsAreAvailable()

            guard let title = note.titlePreview,
                  let _ = title.range(of: normalizedKeyword, options: comparisonOptions, range: title.fullRange, locale: .current)
            else {
                continue
            }

            output.append(note)

            if output.count >= maximumNumberOfResults {
                break
            }
        }

        return output.isEmpty ? nil : output
    }
}

// MARK: - Settings!
//
private enum Settings {
    static let defaultMaximumResults = 15
}
