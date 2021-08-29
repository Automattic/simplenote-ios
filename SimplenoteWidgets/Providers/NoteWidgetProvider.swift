import WidgetKit

struct NoteWidgetEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
    let url: URL
    let loggedIn: Bool
}

extension NoteWidgetEntry {
    init(date: Date, note: Note) {
        self.init(date: date,
                  title: note.title,
                  content: note.body,
                  url: note.url,
                  loggedIn: WidgetDefaults.shared.loggedIn)
    }

    static func placeholder(loggedIn: Bool = true) -> NoteWidgetEntry {
        return NoteWidgetEntry(date: Date(),
                               title: DemoContent.singleNoteTitle,
                               content: DemoContent.singleNoteContent,
                               url: DemoContent.demoURL,
                               loggedIn: loggedIn)
    }

}

struct NoteWidgetProvider: IntentTimelineProvider {
    typealias Intent = NoteWidgetIntent
    typealias Entry = NoteWidgetEntry

    let coreDataManager: CoreDataManager
    let widgetResultsController: WidgetResultsController

    init() {
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
            self.widgetResultsController = WidgetResultsController(context: coreDataManager.managedObjectContext)
        } catch {
            fatalError("Couldn't setup dataController")
        }
    }

    func placeholder(in context: Context) -> NoteWidgetEntry {
        return NoteWidgetEntry.placeholder(loggedIn: WidgetDefaults.shared.loggedIn)
    }

    func getSnapshot(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (NoteWidgetEntry) -> Void) {
        guard WidgetDefaults.shared.loggedIn,
            let note = widgetResultsController.firstNote() else {
            completion(placeholder(in: context))
            return
        }

        completion(NoteWidgetEntry(date: Date(), note: note))
    }

    func getTimeline(for configuration: NoteWidgetIntent, in context: Context, completion: @escaping (Timeline<NoteWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard WidgetDefaults.shared.loggedIn,
              let widgetNote = configuration.note,
              let simperiumKey = widgetNote.identifier,
              let note = widgetResultsController.note(forSimperiumKey: simperiumKey) else {
            completion(Timeline(entries: [placeholder(in: context)], policy: .never))
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
}
