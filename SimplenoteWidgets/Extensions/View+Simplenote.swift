import SwiftUI

extension View {
    func filling() -> some View {
        self.modifier(Filling())
    }
}
