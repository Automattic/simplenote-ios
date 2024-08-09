import WidgetKit

struct NoteWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
    let url: URL
    let state: State

    enum State {
        case standard
        case noteMissing
        case loggedOut
        case pinLockIsEnabled
    }

    var noteIsAvailable: Bool {
        return state != .loggedOut && state != .pinLockIsEnabled
    }
}

extension NoteWidgetEntry {
    init(date: Date, note: Note, state: State = .standard) {
        self.init(date: date,
                  title: note.title,
                  content: note.body,
                  url: note.url,
                  state: state)
    }

    static func placeholder(state: State = .standard) -> NoteWidgetEntry {
        return NoteWidgetEntry(date: Date(),
                               title: DemoContent.singleNoteTitle,
                               content: DemoContent.singleNoteContent,
                               url: DemoContent.demoURL,
                               state: state)
    }

}

struct NoteWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteWidgetEntry

    let coreDataWrapper = ExtensionCoreDataWrapper()

    func placeholder(in context: Context) -> NoteWidgetEntry {
        var state: NoteWidgetEntry.State = if WidgetDefaults.shared.loggedIn == false {
            .loggedOut
        } else if WidgetDefaults.shared.pinLockIsEnabled == true {
            .pinLockIsEnabled
        } else {
            .standard
        }
        return NoteWidgetEntry.placeholder(state: state)
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteWidgetEntry) -> Void) {
        guard WidgetDefaults.shared.loggedIn,
              WidgetDefaults.shared.pinLockIsEnabled == false,
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
        guard WidgetDefaults.shared.pinLockIsEnabled == false else {
            completion(errorTimeline(withState: .pinLockIsEnabled))
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
