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
        print("Displaying snackbar")
        SnackbarPresenter.shared.present(self)
    }
}

class SnackbarPresenter: SnackbarViewControllerDelegate {
    
    static let shared = SnackbarPresenter()
    
    private let DurationShort = 1.5
    private let DurationLong = 2.75

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
        
//        let snackView = prepareView()
        let snackView = prepareViewFromXIB()
        presentView(snackView)
        
        // Puts the view onscreen and returns.
    }

    private func prepareView() -> UIView {
        
        // Prep a test view for display.
        // Limit to 80% of the host window.
        
        let window = UIApplication.shared.keyWindow!
        let width: CGFloat = window.frame.size.width * 0.8
        let height: CGFloat = 60 // Should come from text size?
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = rect.height / 2
        
        return view
    }

    private func prepareViewFromXIB() -> UIView {
        
        let vc = SnackbarViewController()
        
        let view = vc.view!
        let frame = view.frame
        let newFrame = CGRect(x: 0, y: 0, width: frame.width - 30, height: frame.height)
        vc.view.frame = newFrame
        
        let snack = snackbar!
        vc.configureMessageLabel(message: snack.message)
        
        if let title = snack.actionTitle {
            vc.configureActionButton(title: title)
            vc.delegate = self
        }
        
        viewController = vc
        
        return view
    }

    func snackbarActionWasTapped(sender: SnackbarViewController) {
        print("Delegate called for tap.")
        
        wasActionTapped = true
        
        // Remove the view!
        let view = (viewController?.view)!
        self.removeViewNow(view)
    }
    
    private func presentView(_ view: UIView) {
        
        // Determine where the view goes in the host window.
        
        let window = UIApplication.shared.keyWindow!
        
        window.addSubview(view)
        
        // View center should be window width / 2 and window height - offset - (view height / 2)
        
        let viewHeight = view.frame.height
        let offset: CGFloat = 50 // Magic number alert!
        view.center.x = window.frame.size.width / 2
        view.center.y = window.frame.size.height - offset - (viewHeight / 2.0) // Half the view height + the gap from view to screen edge.
        print(view.center)
        print(window.frame.height)
        
        // Now push the view down offscreen.
        view.center.y = view.center.y + offset + viewHeight
        print(view.center.y)
        
        UIView.animate(withDuration: UIKitConstants.animationShortDuration, delay: UIKitConstants.animationDelayZero, options: [], animations: {
            view.center.y = view.center.y - offset - viewHeight
        }) { _ in
            print("Animation complete.")
            self.removeViewAfterTimeout(view)
        }
    }

    private func removeViewAfterTimeout(_ view: UIView) {
        print("Starting countdown to fade...")
        
        let duration = (snackbar?.actionTitle != nil) ? DurationLong : DurationShort
        print(duration)
        
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
