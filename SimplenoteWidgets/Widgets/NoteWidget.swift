import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NoteWidget: Widget {
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: Constants.configurationKind, intent: NoteWidgetIntent.self, provider: NoteWidgetProvider()) { (entry) in
            prepareWidgetView(fromEntry: entry)
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }

    private func prepareWidgetView(fromEntry entry: NoteWidgetEntry) -> some View {
        switch entry.state {
        case .standard:
            return AnyView(NoteWidgetView(entry: entry))
        case .loggedOut:
            return AnyView(WidgetWarningView(warning: .loggedOut))
        case .lockWidgets:
            return AnyView(WidgetWarningView(warning: .noteLocked))
        case .noteMissing:
            return AnyView(WidgetWarningView(warning: .noteMissing))
        }
    }
}

private struct Constants {
    static let configurationKind = "NoteWidget"
    static let displayName = NSLocalizedString("Note", comment: "Note Widget Title")
    static let description = NSLocalizedString("Get quick access to one of your notes.", comment: "Note Widget Description")
}
