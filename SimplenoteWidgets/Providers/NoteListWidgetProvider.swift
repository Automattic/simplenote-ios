import WidgetKit

struct NoteListWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let noteList: [String]
}

struct NoteListWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteListWidgetEntry

    func placeholder(in context: Context) -> NoteListWidgetEntry {
        return NoteListWidgetEntry(date: Date(), title: "Placeholder", noteList: ["Body Placeholder"])
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteListWidgetEntry) -> Void) {
        let entry = NoteListWidgetEntry(date: Date(), title: "Placeholder", noteList: ["Body Placeholder"])

        completion(entry)
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteListWidgetEntry>) -> Void) {
        guard let note = configuration.note else {
            return
        }

        let entry = NoteListWidgetEntry(date: Date(), title: note.identifier ?? "Error", noteList: [""] )
        let timeline = Timeline(entries: [entry], policy: .never)

        completion(timeline)
    }
}
