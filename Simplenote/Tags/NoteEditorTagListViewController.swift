import UIKit

// MARK: - NoteEditorTagListViewControllerDelegate
//
protocol NoteEditorTagListViewControllerDelegate: class {
    func tagListDidUpdate(_ tagList: NoteEditorTagListViewController)
    func tagListIsEditing(_ tagList: NoteEditorTagListViewController)
}

// MARK: - NoteEditorTagListViewController
//
@objc
class NoteEditorTagListViewController: UIViewController {

    @IBOutlet private weak var tagView: TagView! {
        didSet {
            tagView.tagDelegate = self
            tagView.backgroundColor = .clear
            tagView.keyboardAppearance = .simplenoteKeyboardAppearance
        }
    }
    @IBOutlet private weak var tagViewTopConstraint: NSLayoutConstraint!

    private let note: Note
    private let objectManager = SPObjectManager.shared()

    // if a newly created tag is deleted within a certain time span,
    // the tag will be completely deleted - note just removed from the
    // current note. This helps prevent against tag spam by mistyping
    private var recentlyCreatedTag: String?
    private var recentlyCreatedTagTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    weak var delegate: NoteEditorTagListViewControllerDelegate?

    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }

    @objc
    func reload() {
        let tags = note.tagsArray?
            .compactMap({ $0 as? String })
            .filter({ ($0 as NSString).isValidEmailAddress == false })

        tagView.setup(withTagNames: tags ?? [])
    }

    @objc(scrollEntryFieldToVisibleAnimated:)
    func scrollEntryFieldToVisible(animated: Bool) {
        tagView.scrollEntryFieldToVisible(animated: animated)
    }
}


// MARK: - First Responder
//
extension NoteEditorTagListViewController {
    override var isFirstResponder: Bool {
        return tagView.isFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        tagView.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        tagView.resignFirstResponder()
    }
}


// MARK: - SPTagViewDelegate
//
extension NoteEditorTagListViewController: TagViewDelegate {
    func tagView(_ tagView: TagView, shouldCreateTagWithName tagName: String) -> Bool {
        let isEmailAddress = (tagName as NSString).isValidEmailAddress

        if isEmailAddress {
            let alertController = UIAlertController(title: Localization.CollaborationAlert.title.localizedUppercase,
                                                    message: Localization.CollaborationAlert.message,
                                                    preferredStyle: .alert)
            alertController.addCancelActionWithTitle(Localization.CollaborationAlert.cancelAction)
            present(alertController, animated: true, completion: nil)
        }

        return !note.hasTag(tagName) && !isEmailAddress
    }

    func tagView(_ tagView: TagView, didCreateTagWithName tagName: String) {
        if !objectManager.tagExists(tagName) {
            objectManager.createTag(from: tagName)

            recentlyCreatedTag = tagName
            recentlyCreatedTagTimer = Timer.scheduledTimer(withTimeInterval: Constants.clearRecentlyCreatedTagTimeout, repeats: false) { [weak self] (_) in
                self?.recentlyCreatedTagTimer = nil
                self?.recentlyCreatedTag = nil
            }
        }

        note.addTag(tagName)
        delegate?.tagListDidUpdate(self)

        SPTracker.trackEditorTagAdded()
    }

    func tagView(_ tagView: TagView, didRemoveTagWithName tagName: String) {
        note.stripTag(tagName)

        if let recentlyCreatedTag = recentlyCreatedTag, recentlyCreatedTag == tagName {
            self.recentlyCreatedTag = nil
            self.recentlyCreatedTagTimer = nil

            objectManager.removeTagName(recentlyCreatedTag)
        }

        delegate?.tagListDidUpdate(self)

        SPTracker.trackEditorTagRemoved()
    }

    func tagViewDidBeginEditing(_ tagView: TagView) {
        delegate?.tagListIsEditing(self)
    }

    func tagViewDidChange(_ tagView: TagView) {
        delegate?.tagListIsEditing(self)
    }

//    func tagView(_ tagView: TagView!, didChangeAutocompleteVisibility isVisible: Bool) {
//        tagViewTopConstraint.constant = isVisible ? tagView.frame.height : 0
//    }
}


// MARK: - Constants
//
private struct Constants {
    static let clearRecentlyCreatedTagTimeout: TimeInterval = 3.5
}


// MARK: - Localization
//
private struct Localization {
    enum CollaborationAlert {
        static let title = NSLocalizedString("Collaboration has moved", comment: "")
        static let message = NSLocalizedString("Sharing notes is now accessed through the action menu from the toolbar.", comment: "")
        static let cancelAction = NSLocalizedString("OK", comment: "");
    }
}
