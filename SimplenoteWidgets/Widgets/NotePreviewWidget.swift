import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NotePreviewWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Constants.configurationKind, intent: SPNoteWidgetIntent.self, provider: NotePreviewWidgetProvider()) { (entry) in
            NotePreviewWidgetView(entry: entry)
        }
    }
}

private struct Constants {
    static let configurationKind = "NotePreviewWidget"
    static let displayName = NSLocalizedString("New Note", comment: "New Note Widget Title")
    static let description = NSLocalizedString("Create a new note instantly with one tap.", comment: "New Note Widget Description")
}
