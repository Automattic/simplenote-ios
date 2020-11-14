import Foundation

class Snackbar {
    
    fileprivate let message: String
    fileprivate let actionTitle: String?
    fileprivate let actionCompletion: (() -> Void)?
    
    init(message: String) {
        self.message = message
        self.actionTitle = nil
        self.actionCompletion = nil
    }
    
    init(message: String, actionTitle: String, actionCompletion: @escaping () -> Void) {
        self.message = message
        self.actionTitle = actionTitle
        self.actionCompletion = actionCompletion
    }
    
    deinit {
        print("Snackbar deinit")
    }
    
    func show() {
        SnackbarPresenter.shared.present(self)
    }
}

class SnackbarPresenter: SnackbarViewControllerDelegate {
    
    static let shared = SnackbarPresenter()
    
    private var snackbar: Snackbar?
    private var viewController: SnackbarViewController?
    
    private var wasActionTapped = false
    
    // Prevent use outside the shared instance.
    private init() {}

    deinit {
        print("SnackbarPresenter deinit")
        // Should never happen
    }

    func present(_ sender: Snackbar) {
        guard snackbar == nil else {
            print("Already presenting. Please wait.")
            return
        }
        
        snackbar = sender
        wasActionTapped = false
        
        let snackView = prepareViewFromXIB()
        presentView(snackView)
        
        // Puts the view onscreen and returns.
    }

    private func prepareViewFromXIB() -> UIView {
        
        let snack = snackbar!
        let vc = SnackbarViewController()
        var view = vc.view!
        
        if let title = snack.actionTitle {
            vc.configureActiveSnackbar(message: snack.message, buttonTitle: title)
            vc.delegate = self
            view = vc.activeSnackView
        } else {
            vc.configureSimpleSnackbar(message: snack.message)
            view = vc.simpleSnackView
        }
        
        viewController = vc
        
        return view
    }

    func snackbarActionWasTapped(sender: SnackbarViewController) {
        print("Delegate called for tap.")
        
        wasActionTapped = true
        
        // Remove the view!
        let view = (viewController?.activeView())!
        self.removeViewNow(view)
    }
    
    private func presentView(_ view: UIView) {
        
//        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let window = UIApplication.shared.keyWindow!
        window.addSubview(view)

        let conX = view.centerXAnchor.constraint(equalTo: window.centerXAnchor)
        let conBottom = view.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: view.frame.height)
        
        NSLayoutConstraint.activate([conX, conBottom])
        window.layoutIfNeeded()

        UIView.animate(withDuration: 0.25, animations: {
            conBottom.constant = (-view.frame.size.height/2) - window.safeAreaInsets.bottom
            window.layoutIfNeeded()
        }) { _ in
            print("Animation complete.")
            self.removeViewAfterTimeout(view)
        }
    }
    
    private func removeViewAfterTimeout(_ view: UIView) {
        print("Starting countdown to fade...")
        
        let duration = (snackbar?.actionTitle != nil) ? Constants.DurationLong : Constants.DurationShort
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if !self.wasActionTapped {
                print("Hiding snackbar after timeout...")
                self.removeViewNow(view)
            }
        }
    }
    
    private func removeViewNow(_ view: UIView) {
        print("Starting fade...")

        UIView.animate(withDuration: UIKitConstants.animationLongDuration, delay: UIKitConstants.animationDelayZero, options: []) {
            view.alpha = UIKitConstants.alpha0_0
        } completion: { (Bool) in
            view.removeFromSuperview()
            print("Done fade.")
            
            if self.wasActionTapped, let completion = self.snackbar?.actionCompletion {
                completion()
            }
            
            self.snackbar = nil
            self.viewController = nil
        }
    }
}

// MARK: - Constants
//
private struct Constants {
    static let DurationShort = 1.5
    static let DurationLong = 2.75
}
