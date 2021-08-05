import WidgetKit

struct ListWidgetEntry: TimelineEntry {
    let date: Date
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
            self.dataController = try WidgetDataController(coreDataManager: coreDataManager)
        } catch {
            fatalError("Couldn't setup dataController")
        }
    }


    func placeholder(in context: Context) -> ListWidgetEntry {
        return ListWidgetEntry(date: Date())
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        let entry = ListWidgetEntry(date: Date())

        completion(entry)
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        let timeline = Timeline(entries: [ListWidgetEntry(date: Date())], policy: .atEnd)

        completion(timeline)
    }
}
