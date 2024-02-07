import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Constants.configurationKind, provider: NewNoteTimelineProvider()) { entry in
            NewNoteWidgetView()
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()

    }
}

private struct Constants {
    static let configurationKind = "NewNoteWidget"
    static let displayName = NSLocalizedString("New Note", comment: "New Note Widget Title")
    static let description = NSLocalizedString("Create a new note instantly with one tap.", comment: "New Note Widget Description")
}
