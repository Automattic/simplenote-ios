import Foundation
import UIKit


// MARK: - Components Initialization
//
extension SPNoteListViewController {

    /// Sets up the Results Controller
    ///
    @objc
    func configureResultsController() {
        assert(notesListController == nil, "listController is already initialized!")

        notesListController = NotesListController(viewContext: SPAppDelegate.shared().managedObjectContext)
        notesListController.performFetch()
    }

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

    /// Initializes the UITableView <> NoteListController Link. Should be called once both UITableView + ListController have been initialized
    ///
    @objc
    func startDisplayingEntities() {
        tableView.dataSource = self

        notesListController.onBatchChanges = { [weak self] (objectChanges, sectionChanges) in
            self?.tableView.performBatchChanges(objectChanges: objectChanges, sectionChanges: sectionChanges) { _ in
                self?.updateViewIfEmpty()
            }
        }
    }
}


// MARK: - Internal Methods
//
extension SPNoteListViewController {

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

    /// Registers the ListViewController for Peek and Pop events.
    ///
    @objc
    func registerForPeekAndPop() {
        registerForPreviewing(with: self, sourceView: tableView)
    }

    /// Refreshes the Notes ListController Filters + Sorting: We'll also update the UI (TableView + Title) to match the new parameters.
    ///
    @objc
    func refreshListController() {
        let selectedTag = SPAppDelegate.shared().selectedTag
        let filter = NotesListFilter(selectedTag: selectedTag)

        notesListController.filter = filter
        notesListController.sortMode = Options.shared.listSortMode
        notesListController.performFetch()

        tableView.reloadData()
    }

    /// Refreshes the receiver's Title, to match the current filter
    ///
    @objc
    func refreshTitle() {
        title = notesListController.filter.title
    }

    /// Indicates if the Deleted Notes are onScreen
    ///
    @objc
    var isDeletedFilterActive: Bool {
        return notesListController.filter == .deleted
    }

    /// Indicates if the List is Empty
    ///
    @objc
    var isListEmpty: Bool {
        return notesListController.numberOfObjects <= 0
    }

    /// Indicates if we're in Search Mode
    ///
    @objc
    var isSearchActive: Bool {
        return searchText != nil
    }

    /// Returns the SearchText
    ///
    @objc
    var searchText: String? {
        guard case let .searching(keyword) = notesListController.state else {
            return nil
        }

        return keyword
    }
}


// MARK: - UIViewControllerPreviewingDelegate Conformance
//
extension SPNoteListViewController: UIViewControllerPreviewingDelegate {

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard tableView.isUserInteractionEnabled,
            isDeletedFilterActive == false,
            let indexPath = tableView.indexPathForRow(at: location),
            let note = notesListController.object(at: indexPath) as? Note
            else {
                return nil
        }

        /// Prevent any Pan gesture from passing thru
        SPAppDelegate.shared().sidebarViewController.requirePanningToFail()

        /// Mark the source of the interaction
        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        /// Setup the Editor
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
        return notesListController.sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesListController.sections[section].numberOfObjects
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch notesListController.object(at: indexPath) {
        case let note as Note:
            return dequeueAndConfigureCell(for: note, in: tableView, at: indexPath)
        case let tag as Tag:
            return dequeueAndConfigureCell(for: tag, in: tableView, at: indexPath)
        default:
            fatalError()
        }
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


// MARK: - TableViewCell(s) Initialization
//
private extension SPNoteListViewController {

    /// Returns a UITableViewCell configured to display the specified Note
    ///
    func dequeueAndConfigureCell(for note: Note, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SPNoteTableViewCell.self, for: indexPath)

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

        if let keyword = searchText, keyword.count > 0 {
            cell.highlightSubstrings(matching: keyword, color: .simplenoteTintColor)
        }

        return cell
    }

    /// Returns a UITableViewCell configured to display the specified Tag
    ///
    func dequeueAndConfigureCell(for tag: Tag, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
// TODO: Cells
// TODO: Section Headers
// TODO: Tags + Row Heights
// TODO: Tags + didPress
// TODO: Tags + 3D Touch
// TODO: Tags + Swipeable Actions

        let cell = UITableViewCell()
        cell.textLabel?.text = "tag:" + tag.name
        return cell
    }
}


// MARK: - Constants
//
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
