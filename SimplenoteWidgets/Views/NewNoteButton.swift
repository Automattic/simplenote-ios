import SwiftUI
import WidgetKit

struct NewNoteImage: View {
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        ZStack {
            Image(Constants.newNoteImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(foregroundColor)
                .frame(side: size)
        }
        .background(backgroundColor)
    }
}

struct NewNoteButton_Previews: PreviewProvider {
    static var previews: some View {
        NewNoteImage(size: Constants.size, foregroundColor: .white, backgroundColor: .blue)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private struct Constants {
    static let size = CGFloat(48)
    static let newNoteImage = "icon_new_note"
}
