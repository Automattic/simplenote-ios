import SwiftUI
import WidgetKit

struct NotePreviewWidgetView: View {
    var entry: NotePreviewWidgetEntry
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                WidgetHeaderView(text: entry.title)
                    .padding(.bottom, 22)
                Text(entry.body)
                    .font(.body)
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
            .padding(.top, 20)
        }
        .ignoresSafeArea()
    }
}

struct NotePreviewWidgetView_Previews: PreviewProvider {
    static var previews: some View {

        Group {
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), title: title, body: body))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            NotePreviewWidgetView(entry: NotePreviewWidgetEntry(date: Date(), title: title, body: body))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }

    static let title = "Twelve Tone Serialism"
    static let body = "The twelve-tone technique is often closely related with the compositional style, serialism. Fundamentally, twelve-tone serialism is a compositional technique where all 12 notes of the chromatic scale are played with equal frequency throughout the piece without any emphasis on any one note. For this reason, twelve-tone serialism avoids being in any key. Arnold Schoenberg was arguably the most influential composers who embraced the twelve-tone technique. Schoenberg described the system as a “Method of composing with twelve tones which are related only with one another.”"
}
