import SwiftUI
import WidgetKit

struct NoteListRow: View {
    var noteTitle: String
    var width: CGFloat
    var height: CGFloat
    var lastRow: Bool

    var body: some View {
        Text(noteTitle)
            .font(.subheadline)
            .lineLimit(Constants.lineLimit)
            .frame(width: width, height: height, alignment: .leading)
            .foregroundColor(.bodyTextColor)
        Divider()
            .opacity(lastRow ? Double.zero : Constants.fullOpacity)
    }
}

private struct Constants {
    static let fullOpacity = 1.0
    static let lineLimit = 1
}

struct NoteListRow_Previews: PreviewProvider {
    static var previews: some View {
        NoteListRow(noteTitle: "Title for note", width: 300, height: 50, lastRow: false)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

