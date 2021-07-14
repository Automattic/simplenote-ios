import WidgetKit

struct NoteListWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let noteList: [String]
}

struct NoteListWidgetProvider: IntentTimelineProvider {
    typealias Intent = ListWidgetIntent
    typealias Entry = NoteListWidgetEntry

    func placeholder(in context: Context) -> NoteListWidgetEntry {
        return NoteListWidgetEntry(date: Date(), title: "Placeholder", noteList: ["Body Placeholder"])
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (NoteListWidgetEntry) -> Void) {
        let entry = NoteListWidgetEntry(date: Date(), title: "Placeholder", noteList: ["Body Placeholder"])

        completion(entry)
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteListWidgetEntry>) -> Void) {
        guard let list = configuration.list else {
            return
        }

        let entry = NoteListWidgetEntry(date: Date(), title: list.identifier ?? "No List", noteList: [
            "Twelve Tone Serialism",
            "Lorem Ipsum",
            "Post Draft",
            "Meeting Notes, Apr 21",
            "Brain Anatomy",
            "Color Quotes",
            "The Valet’s Tragedy",
            "Lorem Ipsum"
        ] )
        let timeline = Timeline(entries: [entry], policy: .never)

        completion(timeline)
    }
}
