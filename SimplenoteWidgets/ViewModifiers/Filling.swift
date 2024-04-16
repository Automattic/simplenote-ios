import SwiftUI

struct Filling: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(
                minWidth: .zero,
                maxWidth: .infinity,
                minHeight: .zero,
                maxHeight: .infinity,
                alignment: .topLeading
              )
    }
}
