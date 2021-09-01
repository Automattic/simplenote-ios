import SwiftUI
import WidgetKit

struct ListWidgetProcessorView: View {
    let entry: ListWidgetEntry

    var body: some View {
        prepareWidgetView(fromState: entry.state)
    }

    private func prepareWidgetView(fromState state: ListWidgetEntry.State) -> some View {
        switch state {
        case .standard:
            return AnyView(ListWidgetView(entry: entry))
        case .loggedOut:
            return AnyView(WidgetWarningView(warning: .loggedOut))
        case .tagDeleted:
            return AnyView(WidgetWarningView(warning: .tagDeleted))
        }
    }
}

struct ListWidgetProcessorView_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetProcessorView(entry: ListWidgetEntry.placeholder(loggedIn: true, state: .tagDeleted))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
