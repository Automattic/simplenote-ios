import SwiftUI
import WidgetKit

struct ListWidgetView: View {
    var entry: ListWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let numberOfRows: Int = rows(for: widgetFamily)
             HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: .zero) {
                    WidgetHeaderView(text: entry.tag)
                        .padding(.trailing, Constants.sidePadding)
                        .padding([.bottom, .top], Constants.topAndBottomPadding)
                    NoteListTable(entry: entry,
                                  numberOfRows: numberOfRows,
                                  geometry: geometry)
                     .multilineTextAlignment(.leading)
                 }
                .padding(.leading, Constants.sidePadding)
             }
        }
    }

    func rows(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemLarge:
            return Constants.largeRows
        default:
            return Constants.mediumRows
        }
    }
}

private struct Constants {
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
    static let mediumRows = 3
    static let largeRows = 8
    static let sidePadding = CGFloat(20)
    static let topAndBottomPadding = CGFloat(10)
}

struct ListWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            ListWidgetView(entry: ListWidgetEntry(date: Date(), tag: DemoContent.listTag, noteProxys: DemoContent.listProxies))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            ListWidgetView(entry: ListWidgetEntry(date: Date(), tag: DemoContent.listTag, noteProxys: DemoContent.listProxies))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
