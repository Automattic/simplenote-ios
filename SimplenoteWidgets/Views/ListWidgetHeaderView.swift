import SwiftUI
import WidgetKit


struct ListWidgetHeaderView: View {
    let tag: String

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack(alignment: .center) {
            Link(destination: URL.internalUrl(for: tag)) {
                Text(displayName(for: tag))
                    .font(.headline)
                    .foregroundColor(Color(for: colorScheme,
                                           light: .gray100,
                                           dark: .white))
                Spacer()
            }
            Link(destination: URL.newNoteURL(withTag: tag)) {
                NewNoteImage(size: Constants.side,
                             foregroundColor: Color(UIColor(studioColor: .spBlue50)),
                             backgroundColor: Color(for: colorScheme, light: .white, dark: .darkGray1))
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
        ListWidgetHeaderView(tag: "Header")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private struct Constants {
    static let side = CGFloat(24)
}
