import SwiftUI

extension Color {
    static var bodyTextColor: Color {
        Color(light: .gray100, dark: .white)
    }

    static var widgetBackgroundColor: Color {
        Color(light: .white, dark: .darkGray1)
    }

    static var widgetBlueBackgroundColor: Color {
        Color(studioColor: .spBlue50)
    }

    static var widgetTintColor: Color {
        Color(light: .spBlue50, dark: .spBlue30)
    }
}
