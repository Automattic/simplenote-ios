import SwiftUI
import WidgetKit


struct ListWidgetHeaderView: View {
    let text: String

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack(alignment: .center) {
            Link(destination: URL.internalUrl(for: text)) {
                Text(text)
                    .font(.headline)
                    .foregroundColor(Color(for: colorScheme,
                                           light: .gray100,
                                           dark: .white))
                Spacer()
            }
            Link(destination: URL.newNoteURL(withTag: text)) {
                NewNoteImage(size: Constants.side,
                             foregroundColor: Color(UIColor(studioColor: .spBlue50)),
                             backgroundColor: Color(for: colorScheme, light: .white, dark: .darkGray1))
            }
        }
        .padding(.zero)
    }
}

struct NotePreviewHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ListWidgetHeaderView(text: "Header")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private struct Constants {
    static let side = CGFloat(19)
    static let foregroundColor = Color(UIColor(studioColor: .spBlue50))
    static let newNoteHost = "new"
}
