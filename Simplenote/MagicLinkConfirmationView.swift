import Foundation
import SwiftUI
import Gridicons


// MARK: - MagicLinkConfirmationView
//
struct MagicLinkConfirmationView: View {
    let email: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                Image(uiImage: MagicLinkImages.mail)
                    .renderingMode(.template)
                    .foregroundColor(Color(.simplenoteBlue60Color))

                Text("Check your email")
                    .bold()
                    .font(.system(size: Metrics.titleFontSize))
                
                Spacer()
                    .frame(height: Metrics.titlePaddingBottom)
                
                Text("If an account exists, we've sent an email to **\(email)** containing a link that'll log you in.")
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
    }
}


// MARK: - Constants
//
private enum Metrics {
    static let titleFontSize: CGFloat = 22
    static let titlePaddingBottom: CGFloat = 10
    static let detailsFontSize: CGFloat = 17
    static let mailIconSize = CGSize(width: 100, height: 100)
    static let dismissSize = CGSize(width: 30, height: 30)
}

private enum MagicLinkImages {
    static let mail = Gridicon.iconOfType(.mail, withSize: Metrics.mailIconSize)
    static let dismiss = Gridicon.iconOfType(.crossCircle, withSize: Metrics.dismissSize)
}


struct MagicLinkConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        MagicLinkConfirmationView(email: "lord@yosemite.com")
    }
}
