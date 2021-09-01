import SwiftUI
import WidgetKit

struct NoteWidgetProcessorView: View {
    let entry: NoteWidgetEntry

    var body: some View {
        prepareWidgetView(fromState: entry.state)
    }

    private func prepareWidgetView(fromState state: NoteWidgetEntry.State) -> some View {
        switch state {
        case .standard:
            return AnyView(NoteWidgetView(entry: entry))
        case .loggedOut:
            return AnyView(WidgetWarningView(warning: .loggedOut))
        case .noteMissing:
            return AnyView(WidgetWarningView(warning: .noteMissing))
        }
    }
}

struct NoteWidgetProcessorView_Previews: PreviewProvider {
    static var previews: some View {
        NoteWidgetProcessorView(entry: NoteWidgetEntry.placeholder(loggedIn: true, state: .noteMissing))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
