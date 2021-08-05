import SwiftUI
import WidgetKit

struct NewNoteButton: View {
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color

    var body: some View {
        ZStack {
            Image(Constants.newNoteImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .foregroundColor(foregroundColor)
                .frame(width: size, height: size, alignment: .center)
        }
        .background(Color(UIColor(backgroundColor)))
    }
}

struct NewNoteButton_Previews: PreviewProvider {
    static var previews: some View {
        NewNoteButton(size: 48, foregroundColor: .white, backgroundColor: .blue)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private struct Constants {
    static let newNoteImage = "icon_new_note"
}
