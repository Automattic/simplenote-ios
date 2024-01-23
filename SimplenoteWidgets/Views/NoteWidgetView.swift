import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    var entry: NoteWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .widgetHeader(widgetFamily,
                                      color: .bodyTextColor)
                    Text(entry.content)
                        .subheadline(color: .bodyTextColor)
                }
                .filling()
                .padding([.leading, .trailing, .top], Sizes.overallPadding)
                .ignoresSafeArea()
                .widgetURL(entry.url)
            }
            .widgetBackground(content: {
                Color.widgetBackgroundColor
            })
            .redacted(reason: [entry.loggedIn ? [] : .placeholder])
        }
    }
}

private struct Sizes {
    static let overallPadding = CGFloat(20)
}

struct NoteWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteWidgetView(entry: NoteWidgetEntry.placeholder())
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NoteWidgetView(entry: NoteWidgetEntry.placeholder())
                .previewContext(WidgetPreviewContext(family: .systemMedium)).colorScheme(.dark)
        }
    }
}
