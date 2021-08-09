import SwiftUI
import WidgetKit


struct WidgetHeaderView: View {
    let text: String
    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .font(.headline)
            if widgetFamily != .systemSmall {
                Spacer()
                Link(destination: URL(string: SimplenoteConstants.simplenoteScheme + "://" + Constants.newNoteHost)!) {
                    NewNoteButton(size: Constants.side, foregroundColor: Constants.foregroundColor, backgroundColor: .white)
                }
            }
        }
        .padding(0)
    }
}

struct NotePreviewHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetHeaderView(text: "Header")
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

private struct Constants {
    static let side = CGFloat(19)
    static let foregroundColor = Color(UIColor(studioColor: .spBlue50))
    static let newNoteHost = "new"
}
