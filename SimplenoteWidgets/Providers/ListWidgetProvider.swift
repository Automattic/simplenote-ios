import WidgetKit

struct ListWidgetEntry: TimelineEntry {
    let date: Date
    let widgetTag: WidgetTag
    let noteProxies: [ListWidgetNoteProxy]
    let loggedIn: Bool
}

extension ListWidgetEntry {
    init(widgetTag: WidgetTag, noteProxies: [ListWidgetNoteProxy]) {
        self.date = Date()
        self.widgetTag = widgetTag
        self.noteProxies = noteProxies
        self.loggedIn = WidgetDefaults.shared.loggedIn
    }

    static func placeholder(loggedIn: Bool = true) -> ListWidgetEntry {
        return ListWidgetEntry(date: Date(),
                               widgetTag: WidgetTag(kind: .tag, name: DemoContent.listTag),
                               noteProxies: DemoContent.listProxies,
                               loggedIn: loggedIn)

    }
}

struct ListWidgetNoteProxy {
    let title: String
    let url: URL
}

struct ListWidgetProvider: IntentTimelineProvider {
    typealias Intent = ListWidgetIntent
    typealias Entry = ListWidgetEntry

    let coreDataWrapper = WidgetCoreDataWrapper()

    func placeholder(in context: Context) -> ListWidgetEntry {
        return ListWidgetEntry.placeholder(loggedIn: WidgetDefaults.shared.loggedIn)
    }

    func getSnapshot(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (ListWidgetEntry) -> Void) {
        guard WidgetDefaults.shared.loggedIn,
              let allNotes = coreDataWrapper.resultsController()?.notes() else {
            completion(placeholder(in: context))
            return
        }

        let proxies: [ListWidgetNoteProxy] = allNotes.map { (note) -> ListWidgetNoteProxy in
            ListWidgetNoteProxy(title: note.title, url: note.url)
        }

        completion(ListWidgetEntry(widgetTag: WidgetTag(kind: .allNotes), noteProxies: proxies))
    }

    func getTimeline(for configuration: ListWidgetIntent, in context: Context, completion: @escaping (Timeline<ListWidgetEntry>) -> Void) {
        // Confirm valid configuration
        guard WidgetDefaults.shared.loggedIn,
              let widgetTag = configuration.tag,
              let notes = coreDataWrapper.resultsController()?.notes(filteredBy: TagsFilter(from: widgetTag.identifier), limit: Constants.noteFetchLimit) else {
            completion(Timeline(entries: [placeholder(in: context)], policy: .never))
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
            return ListWidgetEntry(date: date, widgetTag: widgetTag, noteProxies: proxies, loggedIn: WidgetDefaults.shared.loggedIn)
        }

        completion(Timeline(entries: entries, policy: .atEnd)
)
    }
}

private struct Constants {
    static let noteFetchLimit = 8
}
