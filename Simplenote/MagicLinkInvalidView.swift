import Foundation
import SwiftUI
import Gridicons


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkInvalidView: View {
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                Image(uiImage: MagicLinkImages.cross)
                    .renderingMode(.template)
                    .foregroundColor(Color(.simplenoteLightBlueColor))

                Text("Invalid Link")
                    .bold()
                    .font(.system(size: Metrics.titleFontSize))
                    .padding()
                
                Text("Your authentication link is no longer valid")
                    .font(.system(size: Metrics.detailsFontSize))
                    .multilineTextAlignment(.center)
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
}

// MARK: - Constants
//
private enum Metrics {
    static let titleFontSize: CGFloat = 22
    static let detailsFontSize: CGFloat = 17
    static let crossIconSize = CGSize(width: 100, height: 100)
    static let dismissSize = CGSize(width: 30, height: 30)
}

private enum MagicLinkImages {
    static let cross = Gridicon.iconOfType(.crossCircle, withSize: Metrics.crossIconSize)
    static let dismiss = Gridicon.iconOfType(.crossCircle, withSize: Metrics.dismissSize)
}
