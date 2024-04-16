import UIKit

// MARK: - SPTextAttachment
//
@objcMembers
class SPTextAttachment: NSTextAttachment {

    /// Extra Sizing Points to be appled over the actual Sizing Font Size
    ///
    var extraDimensionPoints: CGFloat = 4

    /// Indicates if we're in the Checked or Unchecked state
    ///
    var isChecked = false {
        didSet {
            refreshImage()
        }
    }

    /// Updates the Attachment's Tint Color
    ///
    var tintColor: UIColor? {
        didSet {
            refreshImage()
        }
    }

    /// Font to be used for Attachment Sizing purposes
    ///
    var sizingFont: UIFont = .preferredFont(forTextStyle: .headline)

    // MARK: - Overridden Methods

    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        let dimension = sizingFont.pointSize + extraDimensionPoints
        let offsetY = round((sizingFont.capHeight - dimension) * 0.5)

        return CGRect(x: 0, y: offsetY, width: dimension, height: dimension)
    }
}

// MARK: - Private
//
private extension SPTextAttachment {

    func refreshImage() {
        guard let tintColor = tintColor else {
            return
        }

        let name: UIImageName = isChecked ? .taskChecked : .taskUnchecked
        image = UIImage.image(name: name)?.withOverlayColor(tintColor)
    }
}
