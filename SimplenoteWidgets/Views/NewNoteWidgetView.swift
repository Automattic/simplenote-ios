import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidgetView: View {
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    NewNoteButton(size: Constants.side, foregroundColor: .white, backgroundColor: Constants.backgroundColor)
                    Spacer()
                }
                Spacer()
                Text(Constants.newNoteText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(Constants.overallPadding)
        }
        .background(Constants.backgroundColor)
        .widgetURL(URL(string: SimplenoteConstants.simplenoteScheme + "://" + Constants.newNoteHost))
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
    static let backgroundColor = Color(UIColor(studioColor: .spBlue50))
    static let newNoteText = "New Note..."
    static let newNoteHost = "new"
}
