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
    let dataController: WidgetDataController!

    init() {
        NSLog("Created a provider")
        do {
            self.coreDataManager = try CoreDataManager(StorageSettings().sharedStorageURL, for: .widgets)
            let isPreview = ProcessInfo.processInfo.environment[Constants.environmentXcodePreviewsKey] != Constants.isPreviews
            self.dataController = try WidgetDataController(coreDataManager: coreDataManager, isPreview: isPreview)
        } catch {
            fatalError("Couldn't setup dataController")
        }
    }


    func placeholder(in context: Context) -> ListWidgetEntry {
        return ListWidgetEntry.placeholder
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        guard let dataController = dataController else {
            completion(ListWidgetEntry.placeholder)
            return
        }

        guard let allNotes = try? dataController.notes() else {
            completion(ListWidgetEntry.placeholder)
            return
        }

        let proxies: [ListWidgetNoteProxy] = allNotes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        completion(ListWidgetEntry(date: Date(), tag: "All Notes", noteProxys: proxies))
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard let tag = configuration.tag?.identifier,
              let dataController = dataController else {
            NSLog("Couldn't find configuration or identifier")
            return
        }

        // Fetch note
        var notes: [Note]
        do {
            notes = try dataController.notes(withTag: tag, limit: 8)
        } catch {
            NSLog("Couldn't fetch notes from core data")
            return
        }

        let proxies: [ListWidgetNoteProxy] = notes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        // Prepare timeline entry for every hour for the next 6 hours
        // Create a new set of entries at the end of the 6 entries
        var entries: [ListWidgetEntry] = []
        for int in 0..<6 {
            if let date = Date().increased(byHours: int) {
                entries.append(ListWidgetEntry(date: date, tag: tag, noteProxys: proxies))
            }
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)

        completion(timeline)
    }
}

private struct Constants {
    static let tag = "Composition"
    static let environmentXcodePreviewsKey = "XCODE_RUNNING_FOR_PREVIEWS"
    static let isPreviews = "1"
}
