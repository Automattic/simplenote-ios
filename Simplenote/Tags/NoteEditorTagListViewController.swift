import UIKit

// MARK: - NoteEditorTagListViewControllerDelegate
//
protocol NoteEditorTagListViewControllerDelegate: AnyObject {
    func tagListDidUpdate(_ tagList: NoteEditorTagListViewController)
    func tagListIsEditing(_ tagList: NoteEditorTagListViewController)
}

// MARK: - NoteEditorTagListViewController
//
@objc
class NoteEditorTagListViewController: UIViewController {

    @IBOutlet private weak var tagView: TagView! {
        didSet {
            tagView.delegate = self
            tagView.backgroundColor = .clear
            tagView.keyboardAppearance = .simplenoteKeyboardAppearance
        }
    }

    private let note: Note
    private let objectManager = SPObjectManager.shared()
    private let popoverPresenter: PopoverPresenter

    // if a newly created tag is deleted within a certain time span,
    // the tag will be completely deleted - note just removed from the
    // current note. This helps prevent against tag spam by mistyping
    private var recentlyCreatedTag: String?
    private var recentlyCreatedTagTimer: Timer? {
        didSet {
            oldValue?.invalidate()
        }
    }

    private lazy var suggestionsViewController: NoteEditorTagSuggestionsViewController = {
        let viewController = NoteEditorTagSuggestionsViewController(note: note)
        viewController.onSelectionCallback = { [weak self] tagName in
            guard let self = self else {
                return
            }

            self.tagView.addTagFieldText = nil
            self.tagView(self.tagView, wantsToCreateTagWithName: tagName)
        }
        return viewController
    }()

    weak var delegate: NoteEditorTagListViewControllerDelegate?

    init(note: Note, popoverPresenter: PopoverPresenter) {
        self.note = note
        self.popoverPresenter = popoverPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        popoverPresenter.dismiss()
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


// MARK: - Object Manager
//
private extension NoteEditorTagListViewController {
    func createTagIfNotExists(tagName: String) {
        guard !objectManager.tagExists(tagName) else {
            return
        }

        objectManager.createTag(from: tagName)

        recentlyCreatedTag = tagName
        recentlyCreatedTagTimer = Timer.scheduledTimer(withTimeInterval: Constants.clearRecentlyCreatedTagTimeout, repeats: false) { [weak self] (_) in
            self?.recentlyCreatedTagTimer = nil
            self?.recentlyCreatedTag = nil
        }
    }

    func deleteTagIfCreatedRecently(tagName: String) {
        guard let recentlyCreatedTag = recentlyCreatedTag, recentlyCreatedTag == tagName else {
            return
        }

        self.recentlyCreatedTag = nil
        self.recentlyCreatedTagTimer = nil

        objectManager.removeTagName(recentlyCreatedTag)
    }
}


// MARK: - SPTagViewDelegate
//
extension NoteEditorTagListViewController: TagViewDelegate {
    func tagView(_ tagView: TagView, wantsToCreateTagWithName tagName: String) {
        guard !note.hasTag(tagName) else {
            return
        }

        let isEmailAddress = (tagName as NSString).isValidEmailAddress
        guard !isEmailAddress else {
            let alertController = UIAlertController(title: Localization.CollaborationAlert.title,
                                                    message: Localization.CollaborationAlert.message,
                                                    preferredStyle: .alert)
            alertController.addCancelActionWithTitle(Localization.CollaborationAlert.cancelAction)
            present(alertController, animated: true, completion: nil)
            return
        }

        createTagIfNotExists(tagName: tagName)

        note.addTag(tagName)
        tagView.add(tag: tagName)

        delegate?.tagListDidUpdate(self)

        SPTracker.trackEditorTagAdded()

        updateSuggestions()
    }

    func tagView(_ tagView: TagView, wantsToRemoveTagWithName tagName: String) {
        note.stripTag(tagName)
        deleteTagIfCreatedRecently(tagName: tagName)
        tagView.remove(tag: tagName)

        delegate?.tagListDidUpdate(self)

        SPTracker.trackEditorTagRemoved()

        updateSuggestions()
    }

    func tagViewDidBeginEditing(_ tagView: TagView) {
        delegate?.tagListIsEditing(self)
        updateSuggestions()
    }

    func tagViewDidChange(_ tagView: TagView) {
        delegate?.tagListIsEditing(self)
        updateSuggestions()
    }

    private func updateSuggestions() {
        suggestionsViewController.update(with: tagView.addTagFieldText)

        if suggestionsViewController.isEmpty {
            popoverPresenter.dismiss()
            return
        }

        if popoverPresenter.isPresented {
            popoverPresenter.relocate(around: tagView.addTagFieldFrameInWindow)
        } else {
            popoverPresenter.show(suggestionsViewController, around: tagView.addTagFieldFrameInWindow)
        }
    }
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
        static let title = NSLocalizedString("Collaboration has moved", comment: "Alert title that collaboration has moved")
        static let message = NSLocalizedString("Sharing notes is now accessed through the action menu from the toolbar.", comment: "Alert message that collaboration has moved")
        static let cancelAction = NSLocalizedString("OK", comment: "Alert confirmation button title")
    }
}
