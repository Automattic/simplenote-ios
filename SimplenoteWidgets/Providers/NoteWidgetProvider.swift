import WidgetKit

struct NoteWidgetEntry: TimelineEntry {
    static let placeholder = NoteWidgetEntry(date: Date(),
                                             title: DemoContent.singleNoteTitle,
                                             content: DemoContent.singleNoteContent,
                                             url: DemoContent.demoURL)

    init(date: Date, note: Note) {
        self.init(date: date,
                  title: note.title,
                  content: note.body,
                  url: note.url)
    }

    init(date: Date, title: String, content: String, url: URL) {
        self.date = date
        self.title = title
        self.content = content
        self.url = url
    }

    let date: Date
    let title: String
    let content: String
    let url: URL
}

struct NoteWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteWidgetEntry

    let coreDataManager: CoreDataManager!

    init() {
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
        } catch {
            fatalError("Couldn't setup dataController")
        }
    }

    func placeholder(in context: Context) -> NoteWidgetEntry {
        return NoteWidgetEntry.placeholder
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteWidgetEntry) -> Void) {
        guard let note = widgetDataController()?.firstNote() else {
            completion(NoteWidgetEntry.placeholder)
            return
        }

        completion(NoteWidgetEntry(date: Date(), note: note))
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard let widgetNote = configuration.note,
              let simperiumKey = widgetNote.identifier,
              let note = widgetDataController()?.note(forSimperiumKey: simperiumKey) else {
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

    private func widgetDataController() -> WidgetDataController? {
        let isPreview = ProcessInfo.processInfo.environment[WidgetConstants.environmentXcodePreviewsKey] != WidgetConstants.isPreviews
        return try? WidgetDataController(context: coreDataManager.managedObjectContext, isPreview: isPreview)
    }
}
