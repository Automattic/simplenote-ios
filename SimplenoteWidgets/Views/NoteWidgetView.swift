import SwiftUI
import WidgetKit

struct NoteWidgetView: View {
    var entry: NoteWidgetEntry
    @Environment(\.widgetFamily) var widgetFamily
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .leading) {
                    Text(entry.title)
                        .font(widgetFamily == .systemSmall ? .subheadline : .body)
                        .fontWeight(.bold)
                        .foregroundColor(Color(for: colorScheme, light: .gray100, dark: .white))
                    Text(entry.content)
                        .font(.subheadline)
                        .foregroundColor(Color(for: colorScheme, light: .gray100, dark: .white))
                }
                .padding([.leading, .trailing, .top], Sizes.overallPadding)
                .frame(width: geometry.size.width, height: geometry.size.height + Sizes.overallPadding, alignment: .top)
                .ignoresSafeArea()
                .widgetURL(prepareWidgetURL(from: entry.simperiumKey))
            }
            .background(Color(for: colorScheme, light: .white, dark: .darkGray1))
        }
    }

    private func prepareWidgetURL(from simperiumKey: String?) -> URL? {
        guard let simperiumKey = simperiumKey else {
            return URL(string: SimplenoteConstants.simplenoteScheme + "://")!
        }
        return URL(string: Constants.linkUrlBase + simperiumKey)
    }
}

private struct Sizes {
    static let overallPadding = CGFloat(20)
}

private struct Constants {
    static let linkUrlBase = SimplenoteConstants.simplenoteScheme + "://" + SimplenoteConstants.simplenoteInterlinkHost + "/"
}

struct NoteWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: DemoContent.singleNoteTitle, content: DemoContent.singleNoteContent, simperiumKey: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NoteWidgetView(entry: NoteWidgetEntry(date: Date(), title: DemoContent.singleNoteTitle, content: DemoContent.singleNoteContent, simperiumKey: nil))
                .previewContext(WidgetPreviewContext(family: .systemMedium)).colorScheme(.dark)
        }
    }
}
