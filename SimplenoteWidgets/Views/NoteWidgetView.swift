import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    var entry: NoteWidgetEntry
    var body: some View {
        VStack {
            Text(entry.title)
            Text(entry.content)
        }
    }
}

struct NoteWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: "Title", content: "Content"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: "Title", content: "Content"))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
