import Foundation
import CoreSpotlight
import UIKit


// MARK: - Interface Initialization
//
extension SPNoteListViewController {

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        searchBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(navigationBarBackground)
        view.addSubview(searchBar)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.searchBarInsets.left),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.searchBarInsets.right)
        ])

        NSLayoutConstraint.activate([
            navigationBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBarBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBarBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBarBackground.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    /// Adjust the TableView's Insets, so that the content falls below the searchBar
    ///
    @objc
    func refreshTableViewInsets() {
        tableView.contentInset.top = searchBar.frame.height
        tableView.scrollIndicatorInsets.top = searchBar.frame.height
    }

    /// Workaround: Scroll to the very first row. Expected to be called *just* once, right after the view has been laid out, and has been moved
    /// to its parent ViewController.
    ///
    /// Ref. Issue #452
    ///
    @objc
    func ensureFirstRowIsVisible() {
        guard !tableView.isHidden else {
            return
        }

        tableView.contentOffset.y = tableView.adjustedContentInset.top * -1
    }
}


// MARK: - Internal Methods
//
extension SPNoteListViewController {

    /// Registers the ListViewController for Peek and Pop events.
    ///
    @objc
    func registerForPeekAndPop() {
        registerForPreviewing(with: self, sourceView: tableView)
    }

    /// Refreshes the ListViewController's Title
    ///
    @objc
    func refreshTitle() {
        let selectedTag = SPAppDelegate.shared().selectedTag ?? NSLocalizedString("All Notes", comment: "Title: No filters applied")

        switch selectedTag {
        case kSimplenoteTrashKey:
            title = NSLocalizedString("Trash-noun", comment: "Title: Trash Tag is selected")
        case kSimplenoteUntaggedKey:
            title = NSLocalizedString("Untagged", comment: "Title: Untagged Notes are onscreen")
        default:
            title = selectedTag
        }
    }
}


// MARK: - UIViewControllerPreviewingDelegate Conformance
//
extension SPNoteListViewController: UIViewControllerPreviewingDelegate {

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard tableView.isUserInteractionEnabled,
            tagFilterType != .deleted,
            let indexPath = tableView.indexPathForRow(at: location)
            else {
                return nil
        }

        /// Prevent any Pan gesture from passing thru
        SPAppDelegate.shared().sidebarViewController.requirePanningToFail()

        /// Mark the source of the interaction
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        /// Setup the Editor
        let note = fetchedResultsController.object(at: indexPath)
        let editorViewController = SPAppDelegate.shared().noteEditorViewController
        editorViewController.update(note)
        editorViewController.isPreviewing = true
        editorViewController.searchString = searchText

        return editorViewController
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let editorViewController = viewControllerToCommit as? SPNoteEditorViewController else {
            return
        }

        editorViewController.isPreviewing = false
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}


// MARK: - UITableViewDataSource
//
extension SPNoteListViewController: UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? .zero
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? .zero
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SPNoteTableViewCell.reuseIdentifier, for: indexPath) as? SPNoteTableViewCell else {
            fatalError()
        }

        configure(cell: cell, at: indexPath)

        return cell
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


// MARK: - UITableViewDelegate
//
extension SPNoteListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let note = fetchedResultsController.object(at: indexPath)

        switch tagFilterType {
        case .deleted:
            return rowActionsForDeletedNote(note)
        default:
            return rowActionsForNote(note)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard indexPath.row >= (fetchedResultsController.fetchedObjects?.count ?? .zero) else {
            return
        }

        SPRatingsHelper.sharedInstance()?.incrementSignificantEvent()

        let note = fetchedResultsController.object(at: indexPath)
        open(note, from: indexPath, animated: true)
    }
}


// MARK: - TableViewCell(s) Initialization
//
extension SPNoteListViewController {

    /// Sets up a given NoteTableViewCell to display the specified Note
    ///
    @objc(configureCell:atIndexPath:)
    func configure(cell: SPNoteTableViewCell, at indexPath: IndexPath) {
        let note = fetchedResultsController.object(at: indexPath)

        note.ensurePreviewStringsAreAvailable()

        cell.accessibilityLabel = note.titlePreview
        cell.accessibilityHint = NSLocalizedString("Open note", comment: "Select a note to view in the note editor")

        cell.accessoryLeftImage = note.published ? .image(name: .shared) : nil
        cell.accessoryRightImage = note.pinned ? .image(name: .pin) : nil
        cell.accessoryLeftTintColor = .simplenoteNoteStatusImageColor
        cell.accessoryRightTintColor = .simplenoteNoteStatusImageColor

        cell.rendersInCondensedMode = Options.shared.condensedNotesList
        cell.titleText = note.titlePreview
        cell.bodyText = note.bodyPreview

        guard let keyword = searchText, keyword.count > 0 else {
            return
        }

        cell.highlightSubstrings(matching: keyword, color: .simplenoteTintColor)
    }
}


// MARK: - Row Actions
//
private extension SPNoteListViewController {

    func rowActionsForDeletedNote(_ note: Note) -> [UITableViewRowAction] {
        return [
            UITableViewRowAction(style: .default, title: ActionTitle.restore, backgroundColor: .orange) { (_, _) in
                SPObjectManager.shared().restoreNote(note)
                CSSearchableIndex.default().indexSearchableNote(note)
            },

            UITableViewRowAction(style: .destructive, title: ActionTitle.delete, backgroundColor: .red) { (_, _) in
                SPTracker.trackListNoteDeleted()
                SPObjectManager.shared().permenentlyDeleteNote(note)
            }
        ]
    }

    func rowActionsForNote(_ note: Note) -> [UITableViewRowAction] {
        let pinTitle = note.pinned ? ActionTitle.unpin : ActionTitle.pin

        return [
            UITableViewRowAction(style: .destructive, title: ActionTitle.trash, backgroundColor: .simplenoteDestructiveActionColor) { (_, _) in
                SPTracker.trackListNoteDeleted()
                SPObjectManager.shared().trashNote(note)
                CSSearchableIndex.default().deleteSearchableNote(note)
            },

            UITableViewRowAction(style: .default, title: pinTitle, backgroundColor: .simplenoteSecondaryActionColor) { [weak self] (_, _) in
                self?.togglePin(note: note)
            },

            UITableViewRowAction(style: .default, title: ActionTitle.share, backgroundColor: .simplenoteTertiaryActionColor) { [weak self] (_, indexPath) in
                self?.share(note: note, from: indexPath)
            }
        ]
    }

    func togglePin(note: Note) {
        note.pinned = !note.pinned
        SPAppDelegate.shared().save()
    }

    func share(note: Note, from indexPath: IndexPath) {
        guard let _ = note.content, let controller = UIActivityViewController(note: note) else {
            return
        }

        SPTracker.trackEditorNoteContentShared()

        if UIDevice.sp_isPad() {
            controller.modalPresentationStyle = .popover

            let presentationController = controller.popoverPresentationController
            presentationController?.permittedArrowDirections = .any
            presentationController?.sourceRect = tableView.rectForRow(at: indexPath)
            presentationController?.sourceView = tableView
        }

        present(controller, animated: true, completion: nil)
    }
}


// MARK: - Private Types
//
private enum ActionTitle {
    static let delete = NSLocalizedString("Delete", comment: "Trash (verb) - the action of deleting a note")
    static let pin = NSLocalizedString("Pin", comment: "Pin (verb) - the action of Pinning a note")
    static let restore = NSLocalizedString("Restore", comment: "Restore a note from the trash, marking it as undeleted")
    static let share = NSLocalizedString("Share", comment: "Share (verb) - the action of Sharing a note")
    static let trash = NSLocalizedString("Trash-verb", comment: "Trash (verb) - the action of deleting a note")
    static let unpin = NSLocalizedString("Unpin", comment: "Unpin (verb) - the action of Unpinning a note")
}

private enum Constants {

    /// Where do these insets come from?
    /// `For other subviews in your view hierarchy, the default layout margins are normally 8 points on each side`
    ///
    /// We're replicating the (old) view herarchy's behavior, in which the SearchBar would actually be contained within a view with 8pt margins on each side.
    /// This won't be required anymore *soon*, and it's just a temporary workaround.
    ///
    /// Ref. https://developer.apple.com/documentation/uikit/uiview/1622566-layoutmargins
    ///
    static let searchBarInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
}
