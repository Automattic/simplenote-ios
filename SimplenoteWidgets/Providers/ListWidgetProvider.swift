import WidgetKit

struct ListWidgetEntry: TimelineEntry {
    static let placeholder = ListWidgetEntry(date: Date(),
                                             tag: DemoContent.listTag,
                                             noteProxys: DemoContent.listProxies)

    let date: Date
    let tag: String
    let noteProxys: [ListWidgetNoteProxy]
}

struct ListWidgetNoteProxy {
    let title: String
    let url: URL
}

struct ListWidgetProvider: IntentTimelineProvider {
    typealias Intent = ListWidgetIntent
    typealias Entry = ListWidgetEntry

    let coreDataManager: CoreDataManager!

    init() {
        NSLog("Created a provider")
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
        } catch {
            fatalError("Couldn't setup dataController")
        }
    }


    func placeholder(in context: Context) -> ListWidgetEntry {
        return ListWidgetEntry.placeholder
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        guard let allNotes = try? widgetDataController()?.notes() else {
            completion(ListWidgetEntry.placeholder)
            return
        }

        let proxies: [ListWidgetNoteProxy] = allNotes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        completion(ListWidgetEntry(date: Date(), tag: WidgetConstants.allNotesIdentifier, noteProxys: proxies))
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard let tag = configuration.tag?.identifier,
              let notes = try? widgetDataController()?.notes(withFilter: TagsFilter(from: tag), limit: 8) else {
            return
        }

        let proxies: [ListWidgetNoteProxy] = notes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        // Prepare timeline entry for every hour for the next 6 hours
        // Create a new set of entries at the end of the 6 entries
        let entries: [ListWidgetEntry] = Constants.entryRange.compactMap { (index) in
            guard let date = Date().increased(byHours: index) else {
                return nil
            }
            return ListWidgetEntry(date: date, tag: tag, noteProxys: proxies)
        }

        completion(Timeline(entries: entries, policy: .atEnd)
)
    }

    private func widgetDataController() -> WidgetDataController? {
        let isPreview = ProcessInfo.processInfo.environment[Constants.environmentXcodePreviewsKey] != Constants.isPreviews
        return try? WidgetDataController(coreDataManager: coreDataManager, isPreview: isPreview)
    }

    private struct Constants {
        static let environmentXcodePreviewsKey = "XCODE_RUNNING_FOR_PREVIEWS"
        static let isPreviews = "1"
        static let entryRange = 0..<6
    }
}
