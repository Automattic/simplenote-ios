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

    @IBOutlet private weak var tagView: SPTagView! {
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
        if let tags = note.tagsArray as? [String], !tags.isEmpty {
            tagView.setup(withTagNames: tags)
        } else {
            tagView.clearAllTags()
        }
    }

    @objc(scrollEntryFieldToVisibleAnimated:)
    func scrollEntryFieldToVisible(animated: Bool) {
        tagView.scrollEntryFieldToVisible(animated)
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
extension NoteEditorTagListViewController: SPTagViewDelegate {
    func tagView(_ tagView: SPTagView!, shouldCreateTagName tagName: String!) -> Bool {
        return !note.hasTag(tagName)
    }

    func tagView(_ tagView: SPTagView!, didCreateTagName tagName: String!) {
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

    func tagView(_ tagView: SPTagView!, didRemoveTagName tagName: String!) {
        note.stripTag(tagName)

        if let recentlyCreatedTag = recentlyCreatedTag, recentlyCreatedTag == tagName {
            self.recentlyCreatedTag = nil
            self.recentlyCreatedTagTimer = nil

            objectManager.removeTagName(recentlyCreatedTag)
        }

        delegate?.tagListDidUpdate(self)

        SPTracker.trackEditorTagRemoved()
    }

    func tagViewDidBeginEditing(_ tagView: SPTagView!) {
        delegate?.tagListIsEditing(self)
    }

    func tagViewDidChange(_ tagView: SPTagView!) {
        delegate?.tagListIsEditing(self)
    }

    func tagView(_ tagView: SPTagView!, didChangeAutocompleteVisibility isVisible: Bool) {
        tagViewTopConstraint.constant = isVisible ? tagView.frame.height : 0
    }
}


// MARK: - Constants
//
private struct Constants {
    static let clearRecentlyCreatedTagTimeout: TimeInterval = 3.5
}
