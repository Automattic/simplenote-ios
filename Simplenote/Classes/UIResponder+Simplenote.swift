import UIKit

// MARK: - UIResponder
//
extension UIResponder {
    private static weak var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)

        return _currentFirstResponder
    }

    @objc
    private func findFirstResponder(_ sender: Any) {
        UIResponder._currentFirstResponder = self
    }
}
