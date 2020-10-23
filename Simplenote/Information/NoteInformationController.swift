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
        case reference(title: String, date: String)
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

    private let note: Note

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///
    init(note: Note) {
        self.note = note
    }
}

// MARK: - Listening for changes
//
private extension NoteInformationController {
    func startListeningForChanges() {
        noteChangesObserver.delegate = self
    }

    func stopListeningForChanges() {
        noteChangesObserver.delegate = nil
    }
}

// MARK: - Data
//
private extension NoteInformationController {
    func allRows() -> [Row] {
        return metricRows()
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
}

// MARK: - EntityObserverDelegate
//
extension NoteInformationController: EntityObserverDelegate {
    func entityObserver(_ observer: EntityObserver, didObserveChanges identifiers: Set<NSManagedObjectID>) {
        self.observer?(allRows())
    }
}

private struct Localization {
    static let modified = NSLocalizedString("Modified", comment: "Note Modification Date")
    static let created = NSLocalizedString("Created", comment: "Note Creation Date")
    static let words = NSLocalizedString("Words", comment: "Number of words in the note")
    static let characters = NSLocalizedString("Characters", comment: "Number of characters in the note")
}
