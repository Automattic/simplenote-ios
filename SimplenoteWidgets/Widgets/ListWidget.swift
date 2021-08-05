import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct ListWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Constants.configurationKind, intent: ListWidgetIntent.self, provider: ListWidgetProvider()) { (entry) in
            ListWidgetView(entry: entry)
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

private struct Constants {
    static let configurationKind = "ListNoteWidget"
    static let displayName = NSLocalizedString("Note List", comment: "Note List Widget Title")
    static let description = NSLocalizedString("Get quick access to a list of all notes or based on the selected tag.", comment: "Note List Widget Description")
}
