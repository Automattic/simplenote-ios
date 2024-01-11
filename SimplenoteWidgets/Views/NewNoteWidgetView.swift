import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidgetView: View {
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    NewNoteImage(size: Constants.side,
                                 foregroundColor: .white,
                                 backgroundColor: .widgetBlueBackgroundColor)
                    Spacer()
                }
                Spacer()
                Text(Constants.newNoteText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(Constants.overallPadding)
        }
        .widgetBackground(content: {
            Color.widgetBlueBackgroundColor
        })
        .widgetURL(URL.newNoteURL())
    }
}

@available(iOS 14.0, *)
struct NewNoteView_Previews: PreviewProvider {
    static var previews: some View {
        NewNoteWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private struct Constants {
    static let side = CGFloat(48)
    static let overallPadding = CGFloat(16)
    static let newNoteText = NSLocalizedString("New Note...", comment: "Text for new note button")
}
