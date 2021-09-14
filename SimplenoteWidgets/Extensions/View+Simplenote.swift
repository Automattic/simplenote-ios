import SwiftUI

extension View {
    func filling() -> some View {
        self.modifier(Filling())
    }

    func frame(side: CGFloat, alignment: Alignment = .center) -> some View {
        self.frame(width: side, height: side, alignment: alignment)
    }
}
