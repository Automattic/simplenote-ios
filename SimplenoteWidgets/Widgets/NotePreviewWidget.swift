import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NotePreviewWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Constants.configurationKind, intent: SPNoteWidgetIntent.self, provider: NotePreviewWidgetProvider()) { (entry) in
            NotePreviewWidgetView(entry: entry)
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct Constants {
    static let configurationKind = "NotePreviewWidget"
    static let displayName = NSLocalizedString("Note", comment: "Note Widget Title")
    static let description = NSLocalizedString("Get quick access to one of your notes.", comment: "Note Widget Description")
}
