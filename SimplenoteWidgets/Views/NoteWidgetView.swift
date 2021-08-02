import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    var entry: NoteWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(entry.title)
                            .font(widgetFamily == .systemSmall ? .subheadline : .body)
                            .fontWeight(.bold)
                            .padding(.bottom, Sizes.headerPadding)
                        Text(entry.content)
                            .font(.subheadline)
                    }
                    .padding([.leading, .trailing, .top], Sizes.overallPadding)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height + Sizes.overallPadding, alignment: .top)
            .ignoresSafeArea()
        }
        .widgetURL(prepareWidgetURL(from: entry.simperiumKey))
    }

    private func prepareWidgetURL(from simperiumKey: String?) -> URL {
        guard let simperiumKey = simperiumKey,
              let url = URL(string: SimplenoteConstants.simplenoteScheme + "://" + simperiumKey) else {
            return URL(string: SimplenoteConstants.simplenoteScheme)!
        }
        return url
    }
}

private struct Sizes {
    static let overallPadding = CGFloat(20)
    static let headerPadding = CGFloat(10)
}

struct NoteWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: DemoContent.singleNoteTitle, content: DemoContent.singleNoteContent, simperiumKey: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: DemoContent.singleNoteTitle, content: DemoContent.singleNoteContent, simperiumKey: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}
