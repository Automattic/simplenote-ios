import UIKit

// MARK: - SPTagView
//
extension SPTagView {
    @objc
    func validateInput(_ textField: UITextField, range: NSRange, replacement: String) -> Bool {
        let text = (textField.text ?? "")
        guard let range = Range(range, in: text) else {
            return true
        }

        let validator = TagTextFieldInputValidator()
        let result = validator.validateInput(originalText: text, range: range, replacement: replacement)
        switch result {
        case .valid:
            return true
        case .endingWithWhitespace(let text):
            textField.text = text
            processTextInFieldToTag()
            return false
        case .invalid:
            return false
        }
    }
}
