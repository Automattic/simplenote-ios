import SwiftUI
import WidgetKit

struct NotePreviewWidgetView: View {
    var entry: NotePreviewWidgetEntry
    var body: some View {
        Text(entry.text)
    }
}

struct NotePreviewWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), text: "Placeholder Text"))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), text: "Placeholder Text"))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
