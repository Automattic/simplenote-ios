import UIKit

// MARK: - SPTagView
//
extension SPTagView {
    @objc
    func textField(_ textField: UITextField, shouldChangeTo string: String) -> Bool {
        let validator = TagTextFieldInputValidator()
        let result = validator.validate(tag: string)
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
