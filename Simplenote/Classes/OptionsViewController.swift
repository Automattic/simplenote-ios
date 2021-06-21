import Foundation
import UIKit
import SimplenoteFoundation


// MARK: - OptionsControllerDelegate
//
protocol OptionsControllerDelegate: AnyObject {
    func optionsControllerDidPressHistory(_ sender: OptionsViewController)
    func optionsControllerDidPressShare(_ sender: OptionsViewController)
    func optionsControllerDidPressTrash(_ sender: OptionsViewController)
}


// MARK: - OptionsViewController
//
class OptionsViewController: UIViewController {

    /// Options TableView
    ///
    @IBOutlet private var tableView: UITableView!

    /// EntityObserver: Allows us to listen to changes applied to the associated entity
    ///
    private lazy var entityObserver = EntityObserver(context: SPAppDelegate.shared().managedObjectContext, object: note)

    /// Sections onScreen
    ///
    private let sections: [Section] = [
        Section(rows: [.pinToTop, .markdown, .copyInternalURL, .share, .history]),
        Section(rows: [.publish, .copyPublicURL]),
        Section(rows: [.collaborate]),
        Section(rows: [.trash])
    ]

    /// Indicates if we're waiting for an update. If so, we'll skip the next "Reload Interface" call that might come across
    ///
    /// - Important:
    ///     Updating any of the Note Flags (Pinned, Markdown, Published) involves updating the local database.
    ///     Since there is no way to match an Update Request with an actual CoreData refresh event, we'll rely on this simple flag to
    ///     attempt to debounce multiple Switch Toggle events that might happen.
    ///
    ///     Our goal is to prevent a race condition between the user's flip action, and the remote ACK.
    ///
    private var pendingUpdate = false

    /// Note for which we'll render the current Options
    ///
    let note: Note

    /// Options Delegate
    ///
    weak var delegate: OptionsControllerDelegate?

    /// Designated Initializer
    ///
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported!")
    }

    // MARK: - Overridden Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle()
        setupNavigationItem()
        setupTableView()
        setupEntityObserver()
        refreshStyle()
        refreshInterface()
        refreshPreferredSize()
    }
}


// MARK: - Initialization
//
private extension OptionsViewController {

    func setupNavigationTitle() {
        title = NSLocalizedString("Options", comment: "Note Options Title")
    }

    func setupNavigationItem() {
        let doneTitle = NSLocalizedString("Done", comment: "Dismisses the Note Options UI")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: doneTitle,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(doneWasPressed))
    }

    func setupTableView() {
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: SwitchTableViewCell.reuseIdentifier)
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
    }

    func setupEntityObserver() {
        entityObserver.delegate = self
    }

    func refreshPreferredSize() {
        preferredContentSize = tableView.contentSize
    }

    func refreshStyle() {
        view.backgroundColor = .simplenoteTableViewBackgroundColor
        tableView.applySimplenoteGroupedStyle()
    }
}


// MARK: - EntityObserverDelegate
//
extension OptionsViewController: EntityObserverDelegate {

    func entityObserver(_ observer: EntityObserver, didObserveChanges identifiers: Set<NSManagedObjectID>) {
        if pendingUpdate {
            pendingUpdate = false
            return
        }

        refreshInterface()
    }
}


// MARK: - UITableViewDelegate
//
extension OptionsViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        rowWasPressed(indexPath)
    }
}


// MARK: - UITableViewDataSource
//
extension OptionsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAtIndexPath(indexPath)
        return dequeueAndConfigureCell(for: row, at: indexPath, in: tableView)
    }
}


// MARK: - Helper API(s)
//
private extension OptionsViewController {

    func refreshInterface() {
        tableView.reloadData()
    }

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }
}


// MARK: - Building Cells
//
private extension OptionsViewController {

    func dequeueAndConfigureCell(for row: Row, at indexPath: IndexPath, in tableView: UITableView) -> UITableViewCell {
        switch row {
        case .pinToTop:
            return dequeuePinToTopCell(from: tableView, at: indexPath)
        case .markdown:
            return dequeueMarkdownCell(from: tableView, at: indexPath)
        case .copyInternalURL:
            return dequeueCopyInterlinkCell(from: tableView, at: indexPath)
        case .share:
            return dequeueShareCell(from: tableView, at: indexPath)
        case .history:
            return dequeueHistoryCell(from: tableView, at: indexPath)
        case .publish:
            return dequeuePublishCell(from: tableView, at: indexPath)
        case .copyPublicURL:
            return dequeueCopyPublicURLCell(from: tableView, at: indexPath)
        case .collaborate:
            return dequeueCollaborateCell(from: tableView, for: indexPath)
        case .trash:
            return dequeueTrashCell(from: tableView, for: indexPath)
        }
    }

    func dequeuePinToTopCell(from tableView: UITableView, at indexPath: IndexPath) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SwitchTableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .pin)
        cell.title = NSLocalizedString("Pin to Top", comment: "Toggles the Pinned State")
        cell.enabledAccessibilityHint = NSLocalizedString("Unpin note", comment: "Pin State Accessibility Hint")
        cell.disabledAccessibilityHint = NSLocalizedString("Pin note", comment: "Pin State Accessibility Hint")
        cell.isOn = note.pinned
        cell.onChange = { [weak self] newState in
            self?.pinnedWasPressed(newState)
        }

        return cell
    }

    func dequeueMarkdownCell(from tableView: UITableView, at indexPath: IndexPath) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SwitchTableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .note)
        cell.title = NSLocalizedString("Markdown", comment: "Toggles the Markdown State")
        cell.enabledAccessibilityHint = NSLocalizedString("Disable Markdown formatting", comment: "Markdown Accessibility Hint")
        cell.disabledAccessibilityHint = NSLocalizedString("Enable Markdown formatting", comment: "Markdown Accessibility Hint")
        cell.isOn = note.markdown
        cell.onChange = { [weak self] newState in
            self?.markdownWasPressed(newState)
        }

        return cell
    }

    func dequeueCopyInterlinkCell(from tableView: UITableView, at indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .link)
        cell.title = NSLocalizedString("Copy Internal Link", comment: "Copies the Note's Interlink")
        cell.selectable = true
        return cell
    }

    func dequeueShareCell(from tableView: UITableView, at indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .share)
        cell.title = NSLocalizedString("Share", comment: "Opens the Share Sheet")
        return cell
    }

    func dequeueHistoryCell(from tableView: UITableView, at indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .history)
        cell.title = NSLocalizedString("History", comment: "Opens the Note's History")
        return cell
    }

    func dequeuePublishCell(from tableView: UITableView, at indexPath: IndexPath) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SwitchTableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .published)
        cell.title = NSLocalizedString("Publish", comment: "Publishes a Note to the Web")
        cell.enabledAccessibilityHint = NSLocalizedString("Unpublish note", comment: "Publish Accessibility Hint")
        cell.disabledAccessibilityHint = NSLocalizedString("Publish note", comment: "Publish Accessibility Hint")
        cell.isOn = note.published
        cell.onChange = { [weak self] newState in
            self?.publishWasPressed(newState)
        }

        return cell
    }

    func dequeueCopyPublicURLCell(from tableView: UITableView, at indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .copy)
        cell.title = copyLinkText(for: note)
        cell.selectable = canCopyLink(to: note)
        return cell
    }

    func dequeueCollaborateCell(from tableView: UITableView, for indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = .image(name: .collaborate)
        cell.title = NSLocalizedString("Collaborate", comment: "Opens the Collaborate UI")
        return cell
    }

    func dequeueTrashCell(from tableView: UITableView, for indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.title = NSLocalizedString("Move to Trash", comment: "Delete Action")
        cell.imageView?.image = .image(name: .trash)
        return cell
    }
}


// MARK: - Publishing
//
extension OptionsViewController {

    func canCopyLink(to note: Note) -> Bool {
        note.published && note.publishURL.count > .zero
    }

    func copyLinkText(for note: Note) -> String {
        if note.published {
            return note.publishURL.isEmpty ?
                NSLocalizedString("Publishing...", comment: "Indicates the Note is being published") :
                NSLocalizedString("Copy Link", comment: "Copies the Note's Public Link")
        }

        return note.publishURL.isEmpty ?
            NSLocalizedString("Copy Link", comment: "Copies the Note's Public Link") :
            NSLocalizedString("Unpublishing...", comment: "Indicates the Note is being unpublished")
    }

}


// MARK: - Action Handlers
//
private extension OptionsViewController {

    func rowWasPressed(_ indexPath: IndexPath) {
        switch rowAtIndexPath(indexPath) {
        case .copyInternalURL:
            copyInterlinkWasPressed()
        case .share:
            shareWasPressed()
        case .history:
            historyWasPressed()
        case .copyPublicURL:
            copyLinkWasPressed()
        case .collaborate:
            collaborateWasPressed()
        case .trash:
            trashWasPressed()
        default:
            // NO-OP: Switches are handled via closures!
            break
        }
    }

    @IBAction
    func pinnedWasPressed(_ newState: Bool) {
        SPTracker.trackEditorNotePinEnabled(newState)
        SPObjectManager.shared().updatePinnedState(newState, note: note)
        pendingUpdate = true
    }

    @IBAction
    func markdownWasPressed(_ newState: Bool) {
        SPTracker.trackEditorNoteMarkdownEnabled(newState)
        Options.shared.markdown = newState
        SPObjectManager.shared().updateMarkdownState(newState, note: note)
        pendingUpdate = true
    }

    @IBAction
    func copyInterlinkWasPressed() {
        SPTracker.trackEditorCopiedInternalLink()
        UIPasteboard.general.copyInternalLink(to: note)
        NoticeController.shared.present(NoticeFactory.linkCopied())
        SPTracker.trackPresentedNotice(ofType: .internalLinkCopied)
        dismiss(animated: true, completion: nil)
    }

    @IBAction
    func shareWasPressed() {
        delegate?.optionsControllerDidPressShare(self)
    }

    @IBAction
    func historyWasPressed() {
        delegate?.optionsControllerDidPressHistory(self)
    }

    @IBAction
    func publishWasPressed(_ newState: Bool) {
        SPTracker.trackEditorNotePublishEnabled(newState)
        let publishController = SPAppDelegate.shared().publishController
        publishController.updatePublishState(for: note, to: newState)
        pendingUpdate = true
    }

    @IBAction
    func copyLinkWasPressed() {
        guard canCopyLink(to: note) else {
            return
        }

        SPTracker.trackEditorCopiedPublicLink()
        UIPasteboard.general.copyPublicLink(to: note)
        NoticeController.shared.present(NoticeFactory.linkCopied())
        SPTracker.trackPresentedNotice(ofType: .publicLinkCopied)
        dismiss(animated: true, completion: nil)
    }

    @IBAction
    func collaborateWasPressed() {
        SPTracker.trackEditorCollaboratorsAccessed()

        let collaborateViewController = SPAddCollaboratorsViewController()
        collaborateViewController.collaboratorDelegate = self
        collaborateViewController.setup(withCollaborators: note.emailTags)
        navigationController?.pushViewController(collaborateViewController, animated: true)
    }

    @IBAction
    func trashWasPressed() {
        delegate?.optionsControllerDidPressTrash(self)
    }

    @IBAction
    func doneWasPressed() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - SPCollaboratorDelegate
//
extension OptionsViewController: SPCollaboratorDelegate {
    func collaboratorViewController(_ viewController: SPAddCollaboratorsViewController, shouldAddCollaborator collaboratorEmail: String) -> Bool {
        note.hasTag(collaboratorEmail) == false
    }

    func collaboratorViewController(_ viewController: SPAddCollaboratorsViewController, didAddCollaborator collaboratorEmail: String) {
        SPObjectManager.shared().insertTagNamed(collaboratorEmail, note: note)
        SPTracker.trackEditorEmailTagAdded()
    }

    func collaboratorViewController(_ viewController: SPAddCollaboratorsViewController, didRemoveCollaborator collaboratorEmail: String) {
        SPObjectManager.shared().removeTagNamed(collaboratorEmail, note: note)
        SPTracker.trackEditorEmailTagRemoved()
    }
}


// MARK: - Section: Defines a TableView Section
//
private struct Section {
    let rows: [Row]
}


// MARK: - TableView Rows
//
private enum Row {
    case pinToTop
    case markdown
    case copyInternalURL
    case share
    case history
    case publish
    case copyPublicURL
    case collaborate
    case trash
}
