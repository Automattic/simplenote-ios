import Foundation

// MARK: - UIKeyCommand
//
extension UIKeyCommand {
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
