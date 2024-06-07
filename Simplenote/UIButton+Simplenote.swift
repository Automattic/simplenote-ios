import Foundation


extension UIButton {
    
    func setTitleWithoutAnimation(_ title: String?, for state: UIControl.State) {
        UIView.performWithoutAnimation {
            self.setTitle(title, for: state)
            self.layoutIfNeeded()
        }
    }
    
    func setAttributedTitleWithoutAnimation(_ title: NSAttributedString?, for state: UIControl.State) {
        UIView.performWithoutAnimation {
            self.setAttributedTitle(title, for: state)
            self.layoutIfNeeded()
        }
    }
}
