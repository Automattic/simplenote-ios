import UIKit
import Social


typealias CompletionBlock = () -> Void

/// Main VC for Simplenote's Share Extension
///
class ShareViewController: UIViewController {

    /// This completion handler closure is executed when this VC is dismissed.
    ///
    @objc var dismissalCompletionBlock: CompletionBlock?


    // MARK: Private Properties

    @IBOutlet private weak var textView: UITextView!

    /// Returns the Main App's SimperiumToken
    ///
    private var simperiumToken: String? {
        KeychainManager.extensionToken
    }

    /// Indicates if the Markdown flag should be enabled
    ///
    private var isMarkdown: Bool {
        return originalNote?.markdown ?? false
    }

    /// The extension context data provided from the host app
    ///
    private var context: NSExtensionContext?

    /// The original, unmodified note extracted from the NSExtensionContext
    ///
    private var originalNote: Note?

    /// Cancel Bar Button
    ///
    private lazy var cancelButton: UIBarButtonItem = {
        let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel action on share extension.")
        let button = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(cancelWasPressed))
        button.accessibilityIdentifier = "Cancel Button"
        return button
    }()

    /// Next Bar Button
    ///
    private lazy var nextButton: UIBarButtonItem = {
        let nextButtonTitle = NSLocalizedString("Save", comment: "Save action on share extension.")
        let button = UIBarButtonItem(title: nextButtonTitle, style: .plain, target: self, action: #selector(saveWasPressed))
        button.accessibilityIdentifier = "Save Button"
        return button
    }()
    
    /// Keyboard Observer Tokens
    ///
    private var keyboardObserverTokens: [Any] = []


    // MARK: Initialization

    /// Designated Initializer
    ///
    init(context: NSExtensionContext?) {
        self.context = context
        super.init(nibName: type(of: self).nibName, bundle: nil)
        keyboardObserverTokens = addKeyboardObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObservers(with: keyboardObserverTokens)
    }


    // MARK: UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        textView.textContainerInset = Constants.textViewInsets
        loadContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureSimperiumTokenIsValid()
    }
}

extension ShareViewController: KeyboardObservable {
    func keyboardWillChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame else {
            return
        }

        let newKeyboardFloats = endFrame.maxY < view.frame.height
        let offset = UIScreen.main.bounds.height - endFrame.origin.y + Constants.insetBottomBuffer
        let newEdgeInset = newKeyboardFloats ? .zero : offset

        UIView.animate(withDuration: Constants.animationTimeInterval) {
            self.textView.contentInset.bottom = newEdgeInset
            self.textView.scrollIndicatorInsets.bottom = newEdgeInset
        }
    }

    func keyboardDidChangeFrame(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        //currently not used
    }
}

// MARK: - Actions
//
private extension ShareViewController {

    @objc func cancelWasPressed() {
        dismissExtension()
    }

    @objc func saveWasPressed() {
        guard let updatedText = textView.text else {
            dismissExtension()
            return
        }
        guard updatedText.isEmpty == false else {
            // Don't bother saving empty notes.
            dismissExtension()
            return
        }

        let updatedNote = Note(content: updatedText, markdown: isMarkdown)
        submit(note: updatedNote)
        dismissExtension()
    }

    /// Submits a given Note to the user's Simplenote account
    ///
    func submit(note: Note) {
        guard let simperiumToken = simperiumToken else {
            return
        }

        let uploader = Uploader(simperiumToken: simperiumToken)
        uploader.send(note)
    }

    /// Dismiss the extension and call the appropriate completion block
    /// from the original `NSExtensionContext`
    ///
    func dismissExtension() {
        view.endEditing(true)
        dismiss(animated: true, completion: self.dismissalCompletionBlock)
    }
}


// MARK: - Token Validation
//
private extension ShareViewController {

    func ensureSimperiumTokenIsValid() {
        guard isSimperiumTokenInvalid() else {
            return
        }

        displayMissingAccountAlert()
    }

    func isSimperiumTokenInvalid() -> Bool {
        return simperiumToken == nil
    }

    func displayMissingAccountAlert() {
        let title = NSLocalizedString("No Simplenote Account", comment: "Extension Missing Token Alert Title")
        let message = NSLocalizedString("Please log into your Simplenote account first by using the Simplenote app.", comment: "Extension Missing Token Alert Title")
        let accept = NSLocalizedString("Cancel Share", comment: "Name of button to cancel iOS share extension in missing token alert ")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: accept, style: .default) { _ in
            self.cancelWasPressed()
        }

        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Configuration
//
private extension ShareViewController {

    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = nextButton
        navigationItem.title = NSLocalizedString("Simplenote", comment: "Title of main share extension view")
    }

    /// Attempts to extract the Note's Payload from the current ExtensionContext
    ///
    func loadContent() {
        guard let context = context else {
            fatalError()
        }

        context.extractNote(from: context) { note in
            guard let note = note else {
                return
            }
            self.originalNote = note
            self.textView.text = note.content
        }
    }
}

extension UIDevice {
    static var isPad: Bool {
        current.userInterfaceIdiom == .pad
    }
}


// MARK: - Constants
//
private struct Constants {
    static let textViewInsets =  UIEdgeInsets(top: 8.0, left: 12.0, bottom: 8.0, right: 12.0)
    static let insetBottomBuffer = CGFloat(25.0)
    static let animationTimeInterval = TimeInterval(0.5)
}
