import WidgetKit

struct NoteWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
    let url: URL
    let loggedIn: Bool
    let state: State

    enum State {
        case standard
        case noteMissing
        case loggedOut
    }
}

extension NoteWidgetEntry {
    init(date: Date, note: Note, loggedIn: Bool = WidgetDefaults.shared.loggedIn, state: State = .standard) {
        self.init(date: date,
                  title: note.title,
                  content: note.body,
                  url: note.url,
                  loggedIn: loggedIn,
                  state: state)
    }

    static func placeholder(loggedIn: Bool = false, state: State = .standard) -> NoteWidgetEntry {
        return NoteWidgetEntry(date: Date(),
                               title: DemoContent.singleNoteTitle,
                               content: DemoContent.singleNoteContent,
                               url: DemoContent.demoURL,
                               loggedIn: loggedIn,
                               state: state)
    }

}

struct NoteWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteWidgetEntry

    let coreDataWrapper = WidgetCoreDataWrapper()

    func placeholder(in context: Context) -> NoteWidgetEntry {
        return NoteWidgetEntry.placeholder()
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteWidgetEntry) -> Void) {
        guard WidgetDefaults.shared.loggedIn,
              let note = coreDataWrapper.resultsController()?.firstNote() else {
            completion(placeholder(in: context))
            return
        }

        completion(NoteWidgetEntry(date: Date(), note: note))
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard WidgetDefaults.shared.loggedIn else {
            completion(errorTimeline(withState: .loggedOut))
            return
        }

        guard let widgetNote = configuration.note,
              let simperiumKey = widgetNote.identifier,
              let note = coreDataWrapper.resultsController()?.note(forSimperiumKey: simperiumKey) else {
            completion(errorTimeline(withState: .noteMissing))
            return
        }

        // Prepare timeline entry for every hour for the next 6 hours
        // Create a new set of entries at the end of the 6 entries
        let entries: [NoteWidgetEntry] = WidgetConstants.rangeForSixEntries.compactMap({ (index)  in
            guard let date = Date().increased(byHours: index) else {
                return nil
            }
            return NoteWidgetEntry(date: date, note: note)
        })

        let timeline = Timeline(entries: entries, policy: .atEnd)

        completion(timeline)
    }

    private func errorTimeline(withState state: NoteWidgetEntry.State) -> Timeline<NoteWidgetEntry> {
        Timeline(entries: [NoteWidgetEntry.placeholder(state: state)], policy: .never)
    }
}
