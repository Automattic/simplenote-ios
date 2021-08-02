import WidgetKit

struct NoteWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
}

struct NoteWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteWidgetEntry

    func placeholder(in context: Context) -> NoteWidgetEntry {
        return NoteWidgetEntry(date: Date(), title: "Title", content: "Content")
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteWidgetEntry) -> Void) {
        let entry = NoteWidgetEntry(date: Date(), title: "Title", content: "Content")

        completion(entry)
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard let widgetNote = configuration.note,
              let simperiumKey = widgetNote.identifier else {
            NSLog("Couldn't find configuration or identifier")
            return
        }

        // Prepare data controller
        var dataController: WidgetDataController
        do {
            let coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL)
            dataController = try WidgetDataController(coreDataManager: coreDataManager)
        } catch {
            NSLog("Couldn't setup dataController")
            return
        }

        // Fetch note
        guard let note = dataController.note(forSimperiumKey: simperiumKey) else {
            return
        }

        // Prepare timeline entry
        let entry = NoteWidgetEntry(date: Date(), title: note.title, content: note.body)
        let timeline = Timeline(entries: [entry], policy: .never)

        completion(timeline)
    }
}
