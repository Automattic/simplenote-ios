import WidgetKit

struct ListWidgetEntry: TimelineEntry {
    static let placeholder = ListWidgetEntry(date: Date(),
                                    widgetTag: WidgetTag(name: DemoContent.listTag, kind: .tag),
                                    noteProxys: DemoContent.listProxies)

    let date: Date
    let widgetTag: WidgetTag
    let noteProxys: [ListWidgetNoteProxy]
}

struct ListWidgetNoteProxy {
    let title: String
    let url: URL
}

struct ListWidgetProvider: IntentTimelineProvider {
    typealias Intent = ListWidgetIntent
    typealias Entry = ListWidgetEntry

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


    func placeholder(in context: Context) -> ListWidgetEntry {
        return ListWidgetEntry.placeholder
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        guard WidgetDefaults.shared.loggedIn,
              let allNotes = widgetResultsController.notes() else {
            completion(ListWidgetEntry.placeholder)
            return
        }

        let proxies: [ListWidgetNoteProxy] = allNotes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        completion(ListWidgetEntry(date: Date(), widgetTag: WidgetTag.allNotes, noteProxys: proxies))
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard WidgetDefaults.shared.loggedIn,
              let widgetTag = configuration.tag,
              let notes = widgetResultsController.notes(filteredBy: TagsFilter(from: widgetTag.identifier), limit: Constants.noteFetchLimit) else {
            return
        }

        let proxies: [ListWidgetNoteProxy] = notes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        // Prepare timeline entry for every hour for the next 6 hours
        // Create a new set of entries at the end of the 6 entries
        let entries: [ListWidgetEntry] = WidgetConstants.rangeForSixEntries.compactMap { (index) in
            guard let date = Date().increased(byHours: index) else {
                return nil
            }
            return ListWidgetEntry(date: date, widgetTag: widgetTag, noteProxys: proxies)
        }

        completion(Timeline(entries: entries, policy: .atEnd)
)
    }
}

private struct Constants {
    static let noteFetchLimit = 8
}
