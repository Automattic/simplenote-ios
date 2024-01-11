import SwiftUI

extension View {
    func filling() -> some View {
        self.modifier(Filling())
    }

    func frame(side: CGFloat, alignment: Alignment = .center) -> some View {
        self.frame(width: side, height: side, alignment: alignment)
    }
}

extension View {
    func widgetBackground(@ViewBuilder content: ()-> some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                content()
            }
        } else {
            return background(content())
        }
    }
}
