import Foundation

final class NoteInformationController {

    /// Row
    ///
    enum Row {
        /// Metric row
        ///
        case metric(title: String, value: String?)
    }

    /// Observer sends changes in rows
    /// When assigned, it sends current state
    ///
    var observer: (([Row]) -> Void)? {
        didSet {
            observer?(allRows())
        }
    }

    private let note: Note

    /// Designated initializer
    ///
    /// - Parameters:
    ///     - note: Note
    ///
    init(note: Note) {
        self.note = note
    }

    private func allRows() -> [Row] {
        return self.metricRows()
    }

    private func metricRows() -> [Row] {
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

private struct Localization {
    static let modified = NSLocalizedString("Modified", comment: "Note Modification Date")
    static let created = NSLocalizedString("Created", comment: "Note Creation Date")
    static let words = NSLocalizedString("Words", comment: "Number of words in the note")
    static let characters = NSLocalizedString("Characters", comment: "Number of characters in the note")
}
