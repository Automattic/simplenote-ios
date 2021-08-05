import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    var entry: ListWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let numberOfRows: Int = (widgetFamily == .systemLarge) ? 8 : 3
             HStack(alignment: .top) {
                 VStack(alignment: .leading, spacing: 0) {
                    WidgetHeaderView(text: entry.tag)
                        .padding(.trailing, 20)
                        .padding([.bottom, .top], 10)
                     ForEach(0..<numberOfRows) { index in
                         NoteListRow(noteTitle: "string", width: geometry.size.width)
                     }
                     .multilineTextAlignment(.leading)
                 }
                 .padding(.leading, 20)
             }
        }
    }
}

private struct Constants {
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
}

struct ListWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            ListWidgetView(entry: ListWidgetEntry(date: Date(), tag: DemoListContent.tag))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            ListWidgetView(entry: ListWidgetEntry(date: Date(), tag: DemoListContent.tag))
                .previewContext(WidgetPreviewContext(family: .systemLarge)).colorScheme(.dark)
        }
    }
}

private struct DemoListContent {
    static let tag = "Composition"
    static let notes = [
        "Twelve Tone Serialism",
        "Lorem Ipsum",
        "Post Draft",
        "Meeting Notes, Apr 21",
        "Brain Anatomy",
        "Color Quotes",
        "The Valet's Tragedy",
        "Lorem Ipsum"
    ]
}
