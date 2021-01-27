import Foundation

// MARK: - UIKeyCommand
//
extension UIKeyCommand {

    static var inputLeadingArrow: String {
        return UIApplication.isRTL ? UIKeyCommand.inputRightArrow : UIKeyCommand.inputLeftArrow
    }

    static var inputTrailingArrow: String {
        return UIApplication.isRTL ? UIKeyCommand.inputLeftArrow : UIKeyCommand.inputRightArrow
    }

    static let inputReturn = "\r"

    static let inputTab = "\t"

    convenience init(input: String,
                     modifierFlags: UIKeyModifierFlags,
                     action: Selector,
                     title: String? = nil) {
        self.init(input: input, modifierFlags: modifierFlags, action: action)
        
        if let title = title {
            if #available(iOS 13.0, *) {
                self.title = title
            } else {
                discoverabilityTitle = title
            }
        }
    }
}
