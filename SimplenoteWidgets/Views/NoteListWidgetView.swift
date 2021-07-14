import SwiftUI
import WidgetKit

struct NoteListWidgetView: View {
    var entry: NoteListWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        GeometryReader { geometry in
            let numberOfRows: Int = (widgetFamily == .systemLarge) ? 8 : 3
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    WidgetHeaderView(text: entry.title)
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    ForEach(0..<numberOfRows) { index in
                        NoteListRow(noteTitle: NoteTitle(id: index, title: entry.noteList[index]), width: geometry.size.width)
                    }
                    .multilineTextAlignment(.leading)
                }
                .padding(.leading, 20)
            }
        }
    }

    func noteList(from array: [String]) -> [NoteTitle] {
        var titles: [NoteTitle] = []
        var count = 0
        for title in array {
            titles.append(NoteTitle(id: count, title: title))
            count += 1
        }

        return titles
    }
}

struct NoteTitle: Identifiable {
    var id: Int
    var title: String
}

struct NoteListRow: View {
    var noteTitle: NoteTitle
    var width: CGFloat

    var body: some View {
        Text(noteTitle.title)
            .font(.body)
            .lineLimit(1)

            .frame(width: width - 20, height: 40.0, alignment: .leading)
        Divider()
    }

}


struct NoteListWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteListWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            NoteListWidgetView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }

    static var entry = NoteListWidgetEntry(
        date: Date(),
        title: "Composition",
        noteList: [
            "Twelve Tone Serialism",
            "Lorem Ipsum",
            "Post Draft",
            "Meeting Notes, Apr 21",
            "Brain Anatomy",
            "Color Quotes",
            "The Valet’s Tragedy",
            "Lorem Ipsum"
        ])
}
