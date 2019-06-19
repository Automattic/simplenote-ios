import UIKit
import Social
import SAMKeychain


typealias CompletionBlock = () -> Void

/// Main VC for Simplenote's Share Extension
///
class ShareViewController: UIViewController {

    /// This completion handler closure is executed when this VC is dismissed
    ///
    @objc var dismissalCompletionBlock: CompletionBlock?


    // MARK: Private Properties

    /// Returns the Main App's SimperiumToken
    ///
    private var simperiumToken: String? {
        return SAMKeychain.password(forService: kShareExtensionServiceName, account: kShareExtensionAccountName)
    }

    /// Indicates if the Markdown flag should be enabled
    ///
    private var isMarkdown = false

    /// The extension context data provided from the host app
    ///
    private var context: NSExtensionContext?

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


    // MARK: UIViewController Lifecycle

    /// Designated Initializer
    ///
    init(context: NSExtensionContext?) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ensureSimperiumTokenIsValid()
    }
}


// MARK: - Actions
//
private extension ShareViewController {

    @objc func cancelWasPressed() {
        dismiss(animated: true, completion: self.dismissalCompletionBlock)
    }

    @objc func saveWasPressed() {
//        guard let extensionContext = context else {
//            fatalError()
//        }
        guard let note = originalNote else {
            fatalError()
        }

        submit(note: note)
        dismissalCompletionBlock?()
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
        let accept = NSLocalizedString("Cancel Share", comment: "")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: accept, style: .default) { _ in
            self.cancelWasPressed()
        }

        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - Loading!
//
private extension ShareViewController {

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
            self.display(note: note)
        }
    }

    /// Displays a given Note's payload onScreen
    ///
    func display(note: Note) {
        isMarkdown = note.markdown
        //textView.text = note.content
    }

    /// Submits a given Note to the user's Simplenote account
    ///
    func submit(note: Note) {
        guard let simperiumToken = simperiumToken else {
            fatalError()
        }

        let uploader = Uploader(simperiumToken: simperiumToken)
        uploader.send(note)
    }
}
