import SwiftUI
import WidgetKit

struct NoteListRow: View {
    var noteTitle: String
    var width: CGFloat
    var height: CGFloat

    var body: some View {
        Text(noteTitle)
            .font(.subheadline)
            .lineLimit(1)
            .frame(width: width, height: height, alignment: .leading)
        Divider()
    }
}

struct NoteListRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteListRow(noteTitle: "Title for note", width: 300, height: 50)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
