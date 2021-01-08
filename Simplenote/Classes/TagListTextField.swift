import UIKit

// MARK: - TagListTextField
//
class TagListTextField: UITextField {
    override func paste(_ sender: Any?) {
        pasteTag()
    }
}
