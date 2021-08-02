import SwiftUI
import WidgetKit

struct NotePreviewWidgetView: View {
    var entry: NotePreviewWidgetEntry
    var body: some View {
        VStack {
            Text(entry.title)
            Text(entry.content)
        }
    }
}

struct NotePreviewWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), title: "Title", content: "Content"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), title: "Title", content: "Content"))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
