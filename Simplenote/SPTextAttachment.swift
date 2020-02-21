import UIKit


// MARK: - SPTextAttachment
//
@objcMembers
class SPTextAttachment: NSTextAttachment {

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

    /// Updates the Internal Image
    ///
    private func refreshImage() {
        guard let tintColor = tintColor else {
            return
        }

        let name: UIImageName = isChecked ? .taskChecked : .taskUnchecked
        image = UIImage.image(name: name)?.withOverlayColor(tintColor)
    }
}
