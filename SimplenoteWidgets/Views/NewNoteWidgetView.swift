import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidgetView: View {
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(Constants.newNoteImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.white)
                        .frame(width: Constants.side, height: Constants.side, alignment: .center)
                    Spacer()
                }
                Spacer()
                Text(Constants.newNoteText)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(Constants.overallPadding)
        }
        .background(Color.newNoteBackgroundColor)
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
    static let newNoteImage = "icon_new_note"
    static let newNoteText = "New Note..."
    static let newNoteHost = "new"
}
