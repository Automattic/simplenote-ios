import SwiftUI
import WidgetKit


struct ListWidgetHeaderView: View {
    let tag: WidgetTag

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack(alignment: .center) {
            Link(destination: URL.internalUrl(forTag: tag.identifier)) {
                Text(displayName(for: tag.tagDescription))
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

private func displayName(for tag: String) -> String {
    tag.replacingOccurrences(of: "-", with: " ")
}

struct NotePreviewHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetHeaderView(tag: WidgetTag.allNotes)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private struct Constants {
    static let side = CGFloat(24)
}
