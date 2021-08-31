import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    var entry: ListWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: .zero) {
                        ListWidgetHeaderView(tag: entry.widgetTag)
                            .padding(.trailing, Constants.sidePadding)
                            .padding([.bottom, .top], Constants.topAndBottomPadding)
                        NoteListTable(rows: rows,
                                      geometry: geometry)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.leading, Constants.sidePadding)
                }
            }
            .filling()
            .background(Color.widgetBackgroundColor)
            .redacted(reason: entry.loggedIn ? [] : .placeholder)
        }
    }

    func numberOfRows(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemLarge:
            return Constants.largeRows
        default:
            return Constants.mediumRows
        }
    }

    var rows: [Row] {
        let data = entry.noteProxies.map({ Row.note($0) })
        var rows: [Row] = []
        for index in .zero..<numberOfRows(for: widgetFamily) {
            rows.append((data.indices.contains(index)) ? data[index] : .empty)
        }
        return rows
    }
}

enum Row {
    case note(ListWidgetNoteProxy)
    case empty
}


private struct Constants {
    static let mediumRows = 3
    static let largeRows = 8
    static let sidePadding = CGFloat(20)
    static let topAndBottomPadding = CGFloat(10)
}

struct ListWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            ListWidgetView(entry: ListWidgetEntry.placeholder())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            ListWidgetView(entry: ListWidgetEntry.placeholder())
                .previewContext(WidgetPreviewContext(family: .systemLarge))
                .colorScheme(.dark)
        }
    }
}
