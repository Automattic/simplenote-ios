import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
extension Text {
    func widgetHeader(_ widgetFamily: WidgetFamily, color: Color) -> Text {
        self
            .font(widgetFamily == .systemSmall ? .subheadline : .body)
            .fontWeight(.bold)
            .foregroundColor(color)
    }

    func subheadline(color: Color) -> Text {
        self
            .font(.subheadline)
            .foregroundColor(color)
    }
}
