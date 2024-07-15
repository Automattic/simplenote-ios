import Foundation
import SwiftUI
import Gridicons


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkInvalidView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var onPressRequestNewLink: (() -> Void)?
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                Image(uiImage: MagicLinkImages.cross)
                    .renderingMode(.template)
                    .foregroundColor(Color(.simplenoteLightBlueColor))

                Text("Link no longer valid")
                    .bold()
                    .font(.system(size: Metrics.titleFontSize))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, Metrics.titlePaddingBottom)
                
                Button(action: pressedRequestNewLink) {
                    Text("Request a new Link")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding()
                .background(Color(.simplenoteBlue50Color))
                .cornerRadius(Metrics.actionCornerRadius)
                .buttonStyle(PlainButtonStyle())
                
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(uiImage: MagicLinkImages.dismiss)
                            .renderingMode(.template)
                            .foregroundColor(Color(.darkGray))
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        
        /// Force Light Mode (since the Authentication UI is all light!)
        .environment(\.colorScheme, .light)
    }
    
    func pressedRequestNewLink() {
        presentationMode.wrappedValue.dismiss()
        onPressRequestNewLink?()
    }
}


// MARK: - Constants
//
private enum Metrics {
    static let crossIconSize = CGSize(width: 100, height: 100)
    static let dismissSize = CGSize(width: 30, height: 30)
    static let titleFontSize: CGFloat = 20
    static let titlePaddingBottom: CGFloat = 30
    static let actionCornerRadius: CGFloat = 10
}

private enum MagicLinkImages {
    static let cross = Gridicon.iconOfType(.crossCircle, withSize: Metrics.crossIconSize)
    static let dismiss = Gridicon.iconOfType(.crossCircle, withSize: Metrics.dismissSize)
}


// MARK: - Preview
//
struct MagicLinkInvalidView_Previews: PreviewProvider {
    static var previews: some View {
        MagicLinkInvalidView()
    }
}
