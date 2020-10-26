import Foundation
import SimplenoteFoundation

final class NoteInformationController {

    /// Row
    ///
    enum Row {
        /// Metric row
        ///
        case metric(title: String, value: String?)

        /// Reference
        ///
        case reference(interLink: String?, title: String, date: String)

        /// Header
        ///
        case header(title: String)
    }

    /// Observer sends changes in rows
    /// When assigned, it sends current state
    ///
    var observer: (([Row]) -> Void)? {
        didSet {
            observer?(allRows())

            if observer == nil {
                stopListeningForChanges()
            } else {
                startListeningForChanges()
            }
        }
    }

    /// Main Context
    ///
    private var mainContext: NSManagedObjectContext {
        SPAppDelegate.shared().managedObjectContext
    }

    /// Note changes observer
    ///
    private lazy var noteChangesObserver = EntityObserver(context: mainContext, object: note)

    /// ResultsController: In charge of CoreData Queries!
    ///
    private var referencesController: ResultsController<Note>?

    private let note: Note

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///
    init(note: Note) {
        self.note = note

        configureReferencesController()
    }
}

// MARK: - Private
//
private extension NoteInformationController {
    func configureReferencesController() {
        guard let noteLink = note.plainInternalLink else {
            return
        }

        let predicate = NSPredicate.predicateForNotes(exactMatch: noteLink)
        let sortDescriptors = [
            NSSortDescriptor(keyPath: \Note.content, ascending: true)
        ]
        let controller = ResultsController<Note>(viewContext: mainContext,
                                                 sectionNameKeyPath: nil,
                                                 matching: predicate,
                                                 sortedBy: sortDescriptors,
                                                 limit: 0)
        referencesController = controller
        try? controller.performFetch()
    }
}

// MARK: - Listening for changes
//
private extension NoteInformationController {
    func startListeningForChanges() {
        noteChangesObserver.delegate = self

        referencesController?.onDidChangeContent = { [weak self] _, _ in
            self?.sendNewRowsToObserver()
        }
    }

    func stopListeningForChanges() {
        noteChangesObserver.delegate = nil
        referencesController?.onDidChangeContent = nil
    }
}

// MARK: - Data
//
private extension NoteInformationController {
    func allRows() -> [Row] {
        return metricRows() + referenceRows()
    }

    func metricRows() -> [Row] {
        let metrics = NoteMetrics(note: note)
        return [
            .metric(title: Localization.modified,
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.modifiedDate)),

            .metric(title: Localization.created,
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.creationDate)),

            .metric(title: Localization.words,
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfWords)),

            .metric(title: Localization.characters,
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfChars))
        ]
    }

    func referenceRows() -> [Row] {
        guard let references = referencesController?.fetchedObjects, !references.isEmpty else {
            return []
        }

        let referenceRows = references.map { (note) -> Row in
            return .reference(interLink: note.plainInternalLink,
                              title: note.titlePreview,
                              date: DateFormatter.dateFormatter.string(from: note.modificationDate))
        }

        let headerRow = Row.header(title: Localization.references.localizedUppercase)

        return [headerRow] + referenceRows
    }

    func sendNewRowsToObserver() {
        observer?(allRows())
    }
}

// MARK: - EntityObserverDelegate
//
extension NoteInformationController: EntityObserverDelegate {
    func entityObserver(_ observer: EntityObserver, didObserveChanges identifiers: Set<NSManagedObjectID>) {
        sendNewRowsToObserver()
    }
}

private struct Localization {
    static let modified = NSLocalizedString("Modified", comment: "Note Modification Date")
    static let created = NSLocalizedString("Created", comment: "Note Creation Date")
    static let words = NSLocalizedString("Words", comment: "Number of words in the note")
    static let characters = NSLocalizedString("Characters", comment: "Number of characters in the note")
    static let references = NSLocalizedString("References", comment: "References section header on Info Card")
}
