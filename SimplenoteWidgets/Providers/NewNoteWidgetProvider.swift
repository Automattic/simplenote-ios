import WidgetKit

struct NewNoteWidgetEntry: TimelineEntry {
    var date: Date
}

struct NewNoteTimelineProvider: TimelineProvider {
    typealias Entry = NewNoteWidgetEntry

    func placeholder(in context: Context) -> NewNoteWidgetEntry {
        return NewNoteWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (NewNoteWidgetEntry) -> Void) {
        let entry = NewNoteWidgetEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewNoteWidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [NewNoteWidgetEntry(date: Date())], policy: .never)
        completion(timeline)
    }
}
