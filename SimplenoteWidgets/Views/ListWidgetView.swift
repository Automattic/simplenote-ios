import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    var entry: ListWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Text("Temporary Text")
            }
            .background(Color(for: colorScheme, light: .white, dark: .darkGray1))
        }
    }
}

private struct Constants {
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
}

struct ListWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            ListWidgetView(entry: ListWidgetEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            ListWidgetView(entry: ListWidgetEntry(date: Date()))
                .previewContext(WidgetPreviewContext(family: .systemLarge)).colorScheme(.dark)
        }
    }
}
