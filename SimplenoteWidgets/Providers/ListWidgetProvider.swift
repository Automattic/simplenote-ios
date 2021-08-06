import WidgetKit

struct ListWidgetEntry: TimelineEntry {
    let date: Date
    let tag: String
    let noteProxys: [ListWidgetNoteProxy]
}

struct ListWidgetNoteProxy {
    let title: String
    let url: String
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
        return ListWidgetEntry(date: Date(), tag: DemoContent.listTag, noteProxys: DemoContent.listProxies)
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        let entry = ListWidgetEntry(date: Date(), tag: DemoContent.listTag, noteProxys: DemoContent.listProxies)

        completion(entry)
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [ListWidgetEntry(date: Date(), tag: DemoContent.listTag, noteProxys: DemoContent.listProxies)], policy: .atEnd)

        completion(timeline)
    }
}

private struct Constants {
    static let tag = "Composition"
    static let environmentXcodePreviewsKey = "XCODE_RUNNING_FOR_PREVIEWS"
    static let isPreviews = "1"
}
