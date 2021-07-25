import WidgetKit

struct NotePreviewWidgetEntry: TimelineEntry {
    let date: Date
    let text: String
}

struct NotePreviewWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NotePreviewWidgetEntry

    func placeholder(in context: Context) -> NotePreviewWidgetEntry {
        return NotePreviewWidgetEntry(date: Date(), text: "Placeholder")
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NotePreviewWidgetEntry) -> Void) {
        let entry = NotePreviewWidgetEntry(date: Date(), text: "Placeholder")

        completion(entry)
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NotePreviewWidgetEntry>) -> Void) {
        guard let note = configuration.note else {
            return
        }

        let entry = NotePreviewWidgetEntry(date: Date(), text: note.identifier ?? "Error")
        let timeline = Timeline(entries: [entry], policy: .never)

        completion(timeline)
    }
}
