import SwiftUI
import WidgetKit

struct WidgetWarningView: View {
    let warning: WidgetsState
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Text(warning.message)
                    .subheadline(color: .bodyTextColor)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
            .filling()
        }
        .padding()
        .background(Color.widgetBackgroundColor)
        .widgetURL(URL(string: .simplenotePath()))
    }
}

struct WidgetWarningView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetWarningView(warning: .tagDeleted)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        WidgetWarningView(warning: .noteMissing)
            .previewContext(WidgetPreviewContext(family: .systemMedium)).colorScheme(.dark)
        WidgetWarningView(warning: .tagDeleted)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
