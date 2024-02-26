import Foundation
import UIKit

// MARK: - SPLabel: Standard UIKit Label with extra properties. And batteries!
//
@IBDesignable
class SPLabel: UILabel {

    /// # Insets to be applied over the actual text
    ///
    @IBInspectable var textInsets = UIEdgeInsets.zero

    // MARK: - Overrides

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize

        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
}
