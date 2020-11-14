import UIKit

protocol SnackbarViewControllerDelegate: AnyObject {
    func snackbarActionWasTapped(sender: SnackbarViewController)
}

class SnackbarViewController: UIViewController {
    
    @IBOutlet weak var simpleSnackView: UIView!
    @IBOutlet weak var activeSnackView: UIView!
    
    @IBOutlet weak var simpleMessageLabel: UILabel!
    @IBOutlet weak var activeMessageLabel: UILabel!

    @IBOutlet weak var actionButton: UIButton!

    weak var delegate: SnackbarViewControllerDelegate?
    
    deinit {
        print("VC deinit.")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Simple snack config.
        simpleSnackView.layer.cornerRadius = simpleSnackView.frame.height / 2
        simpleSnackView.backgroundColor = SPUserInterface.isDark ? .darkGray : .lightGray
        simpleMessageLabel.textColor = SPUserInterface.isDark ? .white : .black
        
        // Active snack config.
        activeSnackView.layer.cornerRadius = activeSnackView.frame.height / 2
        activeSnackView.backgroundColor = SPUserInterface.isDark ? .darkGray : .lightGray
        activeMessageLabel.textColor = SPUserInterface.isDark ? .white : .black
    }
    
    func configureSimpleSnackbar(message: String) {
        simpleMessageLabel.text = message
    }
    
    func configureActiveSnackbar(message: String, buttonTitle title: String) {
        activeMessageLabel.text = message
        actionButton.isHidden = false
        actionButton.setTitle(title, for: .normal)
    }
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        print("Tapped!")
        actionButton.isEnabled = false
        delegate?.snackbarActionWasTapped(sender: self)
    }
    
    func activeView() -> UIView {
        
        return (delegate == nil) ? simpleSnackView : activeSnackView
    }
}
