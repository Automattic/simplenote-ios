import SwiftUI
import WidgetKit


struct ListWidgetHeaderView: View {
    let tag: WidgetTag

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack(alignment: .center) {
            Link(destination: URL.internalUrl(forTag: tag.identifier)) {
                Text(tag.tagDescription)
                    .font(.headline)
                    .foregroundColor(.bodyTextColor)
                Spacer()
            }
            Link(destination: URL.newNoteURL(withTag: tag.identifier)) {
                NewNoteImage(size: Constants.side,
                             foregroundColor: .widgetTintColor,
                             backgroundColor: .widgetBackgroundColor)
            }
        }
        .padding(.zero)
    }
}

struct NotePreviewHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetHeaderView(tag: WidgetTag(kind: .allNotes))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private struct Constants {
    static let side = CGFloat(24)
}
