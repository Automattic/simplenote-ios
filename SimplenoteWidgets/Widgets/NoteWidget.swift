import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NoteWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Constants.configurationKind, intent: NoteWidgetIntent.self, provider: NoteWidgetProvider()) { (entry) in
            NoteWidgetProcessorView(entry: entry)
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct Constants {
    static let configurationKind = "NoteWidget"
    static let displayName = NSLocalizedString("Note", comment: "Note Widget Title")
    static let description = NSLocalizedString("Get quick access to one of your notes.", comment: "Note Widget Description")
}
