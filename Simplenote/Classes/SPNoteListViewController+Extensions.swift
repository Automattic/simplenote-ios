import Foundation
import CoreSpotlight
import UIKit
import SimplenoteSearch

// MARK: - Components Initialization
//
extension SPNoteListViewController {

    /// Sets up the Feedback Generator!
    ///
    @objc
    func configureImpactGenerator() {
        feedbackGenerator = UIImpactFeedbackGenerator()
        feedbackGenerator.prepare()
    }

    /// Sets up the main TableView
    ///
    @objc
    func configureTableView() {
        assert(tableView == nil, "tableView is already initialized!")

        tableView = UITableView()
        tableView.delegate = self

        tableView.alwaysBounceVertical = true
        tableView.tableFooterView = UIView()

        tableView.layoutMargins = .zero
        tableView.separatorStyle = .none

        tableView.register(SPNoteTableViewCell.loadNib(), forCellReuseIdentifier: SPNoteTableViewCell.reuseIdentifier)
        tableView.register(SPTagTableViewCell.loadNib(), forCellReuseIdentifier: SPTagTableViewCell.reuseIdentifier)
        tableView.register(SPSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SPSectionHeaderView.reuseIdentifier)

        tableView.allowsMultipleSelectionDuringEditing = true
    }

    /// Sets up the Results Controller
    ///
    @objc
    func configureResultsController() {
        assert(notesListController == nil, "listController is already initialized!")

        notesListController = NotesListController(viewContext: SPAppDelegate.shared().managedObjectContext)
        notesListController.performFetch()
    }

    /// Sets up the Placeholder View
    ///
    @objc
    func configurePlaceholderView() {
        placeholderView = SPPlaceholderView()
    }

    /// Sets up the Search StackView
    /// - Note: We're embedding the SearchBar inside a StackView, to aid in the SearchBar-Hidden Mechanism
    ///
    @objc
    func configureSearchStackView() {
        assert(searchBar != nil, "searchBar must be initialized first!")

        searchBarStackView = UIStackView(arrangedSubviews: [searchBar])
        searchBarStackView.axis = .vertical
    }

    /// Sets up the Root ViewController
    ///
    @objc
    func configureRootView() {
        navigationBarBackground.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        searchBarStackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(placeholderView)
        view.addSubview(navigationBarBackground)
        view.addSubview(searchBarStackView)

        NSLayoutConstraint.activate([
            searchBarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.searchBarInsets.left),
            searchBarStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.searchBarInsets.right)
        ])

        NSLayoutConstraint.activate([
            navigationBarBackground.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBarBackground.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBarBackground.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBarBackground.bottomAnchor.constraint(equalTo: searchBarStackView.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let placeholderVerticalCenterConstraint = placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        placeholderViewVerticalCenterConstraint = placeholderVerticalCenterConstraint

        let placeholderTopConstraint = placeholderView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: Constants.searchEmptyStateTopMargin)
        placeholderViewTopConstraint = placeholderTopConstraint

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderVerticalCenterConstraint,
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            placeholderView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            placeholderView.bottomAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.bottomAnchor)
        ])

    }

    /// Initializes the UITableView <> NoteListController Link. Should be called once both UITableView + ListController have been initialized
    ///
    @objc
    func startDisplayingEntities() {
        tableView.dataSource = self

        notesListController.onBatchChanges = { [weak self] (sectionsChangeset, objectsChangeset) in
            guard let `self` = self else {
                return
            }

            /// Note:
            ///  1. State Restoration might cause this ViewController not to be onScreen
            ///  2. When that happens, any remote change might cause a Batch Update
            ///  3. And the above yields a crash
            ///
            /// In this snipept we're preventing a beautiful `_Bug_Detected_In_Client_Of_UITableView_Invalid_Number_Of_Rows_In_Section` exception
            ///
            guard let _ = self.view.window else {
                self.reloadTableData()
                self.displayPlaceholdersIfNeeded()
                return
            }

            self.tableView.performBatchChanges(sectionsChangeset: sectionsChangeset, objectsChangeset: objectsChangeset) { _ in
                self.displayPlaceholdersIfNeeded()
                self.refreshEmptyTrashState()
            }
            self.updateCurrentSelection()
        }
    }
}


// MARK: - Internal Methods
//
extension SPNoteListViewController {

    /// Adjust the TableView's Insets, so that the content falls below the searchBar
    ///
    @objc
    func refreshTableViewTopInsets() {
        tableView.contentInset.top = searchBarStackView.frame.height
        tableView.scrollIndicatorInsets.top = searchBarStackView.frame.height
    }

    /// Scrolls to the First Row whenever the flag `mustScrollToFirstRow` was set to true
    ///
    @objc
    func ensureFirstRowIsVisibleIfNeeded() {
        guard mustScrollToFirstRow else {
            return
        }

        ensureFirstRowIsVisible()
        mustScrollToFirstRow = false
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

    /// Refreshes the Notes ListController Filters + Sorting: We'll also update the UI (TableView + Title) to match the new parameters.
    ///
    @objc
    func refreshListController() {
        let selectedTag = SPAppDelegate.shared().selectedTag
        let filter = NotesListFilter(selectedTag: selectedTag)

        notesListController.filter = filter
        notesListController.sortMode = Options.shared.listSortMode
        notesListController.performFetch()

        reloadTableData()
    }

    /// Refreshes the receiver's Title, to match the current filter
    ///
    @objc
    func refreshTitle() {
        title = searchController.active ? NSLocalizedString("Search", comment: "Search Title") : notesListController.filter.title
    }

    /// Toggles the SearchBar's Visibility, based on the active Filter.
    ///
    /// - Note: We're marking `mustScrollToFirstRow`, which will cause the layout pass to run `ensureFirstRowIsVisible`.
    ///         Changing the SearchBar Visibility triggers a layout pass, which updates the Table's Insets, and scrolls up to the first row.
    ///
    @objc
    func refreshSearchBar() {
        guard searchBar.isHidden != isDeletedFilterActive else {
            return
        }

        mustScrollToFirstRow = true
        searchBar.isHidden = isDeletedFilterActive
    }

    /// Refreshes the SearchBar's Text (and backfires the NoteListController filtering mechanisms!)
    ///
    func refreshSearchText(appendFilterFor tag: Tag) {
        let keyword = SearchQuerySettings.default.tagsKeyword + tag.name
        let updated = searchBar.text?.replaceLastWord(with: keyword) ?? keyword

        searchController.updateSearchText(searchText: updated + .space)
    }

    /// Displays the Emtpy State Placeholders, when / if needed
    ///
    @objc
    func displayPlaceholdersIfNeeded() {
        guard isListEmpty else {
            placeholderView.isHidden = true
            return
        }

        placeholderView.isHidden = false
        placeholderView.displayMode = placeholderDisplayMode

        updatePlaceholderPosition()
    }

    func refreshSelectAllLabels() {
        let numberOfSelectedRows = tableView.indexPathsForSelectedRows?.count ?? 0
        let deselect = notesListController.numberOfObjects == numberOfSelectedRows

        selectAllButton.title = Localization.selectAllLabel(deselect: deselect)
        selectAllButton.isAccessibilityElement = true
        selectAllButton.accessibilityLabel = Localization.selectAllLabel(deselect: deselect)
        selectAllButton.accessibilityHint = Localization.selectAllAccessibilityHint
    }

    private var placeholderDisplayMode: SPPlaceholderView.DisplayMode {
        if isIndexingNotes || SPAppDelegate.shared().bSigningUserOut {
            return .generic
        }

        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            let actionHandler: () -> Void = { [weak self] in
                self?.openNewNote(with: searchQuery.searchText)
            }
            return .text(text: Localization.EmptyState.searchTitle,
                         actionText: Localization.EmptyState.searchAction(with: searchQuery.searchText),
                         actionHandler: actionHandler)
        }

        switch notesListController.filter {
        case .everything:
            return .pictureAndText(imageName: .allNotes, text: Localization.EmptyState.allNotes)
        case .deleted:
            return .pictureAndText(imageName: .trash, text: Localization.EmptyState.trash)
        case .untagged:
            return .pictureAndText(imageName: .untagged, text: Localization.EmptyState.untagged)
        case .tag(name: let name):
            return .pictureAndText(imageName: .tag, text: Localization.EmptyState.tagged(with: name))
        }
    }

    private func updatePlaceholderPosition() {
        if case .text = placeholderView.displayMode {
            placeholderViewVerticalCenterConstraint.isActive = false
            placeholderViewTopConstraint.isActive = true
        } else {
            placeholderViewTopConstraint.isActive = false
            placeholderViewVerticalCenterConstraint.isActive = true
        }
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
        return searchController.active
    }

    /// Returns the SearchText
    ///
    @objc
    var searchQuery: SearchQuery? {
        guard case let .searching(query) = notesListController.state else {
            return nil
        }

        return query
    }

    /// Creates and opens new note with a given text
    ///
    func openNewNote(with content: String) {
        SPTracker.trackListNoteCreated()
        let note = SPObjectManager.shared().newDefaultNote()
        note.content = content
        if case let .tag(name) = notesListController.filter {
            note.addTag(name)
        }
        open(note, ignoringSearchQuery: true, animated: true)
    }

    /// Sets the state of the trash button
    ///
    @objc
    func refreshEmptyTrashState() {
        let isTrashOnScreen = self.isDeletedFilterActive
        let isNotEmpty = !self.isListEmpty

        emptyTrashButton.isEnabled = isTrashOnScreen && isNotEmpty
    }

    /// Delete selected notes
    ///
    @objc
    func trashSelectedNotes() {
        guard let notes = tableView.indexPathsForSelectedRows?.compactMap({ notesListController.object(at: $0) as? Note }) else {
            return
        }

        delete(notes: notes)
        setEditing(false, animated: true)
    }

    /// Setup Navigation toolbar buttons
    ///
    @objc
    func configureNavigationToolbarButton() {
        // TODO: When multi select is added to iPad, revist the conditionals here
        guard let trashButton = trashButton else {
            return
        }
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems([flexibleSpace, trashButton], animated: true)
    }

    @objc
    func selectAllWasTapped() {
        if notesListController.numberOfObjects == tableView.indexPathsForSelectedRows?.count {
            tableView.deselectAllRows(inSection: .zero, animated: false)
        } else {
            tableView.selectAllRows(inSection: 0, animated: false)
        }
        refreshNavigationBarLabels()
        refreshTrashButton()
    }

    @objc
    func refreshNavigationBarLabels() {
        refreshListViewTitle()
        refreshSelectAllLabels()
    }

    @objc
    func refreshEditButtonTitle() {
        editButtonItem.title = isEditing ? Localization.cancelTitle : Localization.editTitle
    }

    func refreshTrashButton() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else {
            trashButton.isEnabled = false
            return
        }
        trashButton.isEnabled = selectedRows.count > 0
    }
}


// MARK: - UIScrollViewDelegate
//
extension SPNoteListViewController: UIScrollViewDelegate {

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard searchBar.isFirstResponder, searchBar.text?.isEmpty == false else {
            return
        }

        searchBar.resignFirstResponder()
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = notesListController.sections[section]
        guard section.displaysTitle else {
            return nil
        }

        return section.title
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard notesListController.sections[section].displaysTitle else {
            return nil
        }

        return tableView.dequeueReusableHeaderFooterView(ofType: SPSectionHeaderView.self)
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

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Notes:
        //  1.  No need to estimate. We precalculate the Height elsewhere, and we can return the *Actual* value
        //  2.  We always scroll to the first row whenever Search Results are updated. If we don't implement this method,
        //      UITableView ends up jumping off elsewhere!
        //
        return self.tableView(tableView, heightForRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch notesListController.object(at: indexPath) {
        case is Note:
            return noteRowHeight
        case is Tag:
            return tagRowHeight
        default:
            return .zero
        }
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        guard notesListController.sections[section].displaysTitle else {
            return .leastNormalMagnitude
        }

        return Constants.estimatedHeightForHeaderInSection
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard notesListController.sections[section].displaysTitle else {
            return .leastNormalMagnitude
        }

        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Swipeable Actions: Only enabled for Notes
        guard let note = notesListController.object(at: indexPath) as? Note else {
            return nil
        }

        return UISwipeActionsConfiguration(actions: contextActions(for: note))
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            refreshNavigationBarLabels()
            refreshTrashButton()
            return
        }

        selectedNote = nil

        switch notesListController.object(at: indexPath) {
        case let note as Note:
            SPRatingsHelper.sharedInstance()?.incrementSignificantEvent()
            open(note, animated: true)
        case let tag as Tag:
            refreshSearchText(appendFilterFor: tag)
        default:
            break
        }

    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if isEditing {
            refreshNavigationBarLabels()
            refreshTrashButton()
        }
    }

    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard isDeletedFilterActive == false, isEditing == false, let note = notesListController.object(at: indexPath) as? Note else {
            return nil
        }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            return self.previewingViewController(for: note)

        }, actionProvider: { suggestedActions in
            return self.contextMenu(for: note, at: indexPath)
        })
    }

    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let editorViewController = animator.previewViewController as? SPNoteEditorViewController else {
            return
        }

        animator.addCompletion {
            editorViewController.isPreviewing = false
            self.show(editorViewController, sender: self)
        }
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SPNoteTableViewCell else {
            return
        }

        var insets = SPNoteTableViewCell.separatorInsets
        insets.left -= cell.layoutMargins.left

        cell.separatorInset = insets

        cell.shouldDisplayBottomSeparator = indexPath.row < notesListController.numberOfObjects - 1 && !UIDevice.isPad
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

        cell.accessoryLeftImage = note.pinned ? .image(name: .pinSmall) : nil
        cell.accessoryRightImage = note.published ? .image(name: .shared) : nil
        cell.accessoryLeftTintColor = .simplenoteNotePinStatusImageColor
        cell.accessoryRightTintColor = .simplenoteNoteShareStatusImageColor

        cell.rendersInCondensedMode = Options.shared.condensedNotesList
        cell.titleText = note.titlePreview
        cell.bodyText = note.bodyExcerpt(keywords: searchQuery?.keywords)

        cell.keywords = searchQuery?.keywords
        cell.keywordsTintColor = .simplenoteTintColor

        cell.prefixText = prefixText(for: note)

        cell.refreshAttributedStrings()

        return cell
    }

    /// Returns a UITableViewCell configured to display the specified Tag
    ///
    func dequeueAndConfigureCell(for tag: Tag, in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SPTagTableViewCell.self, for: indexPath)
        cell.leftImage = .image(name: .tag)
        cell.leftImageTintColor = .simplenoteNoteShareStatusImageColor
        cell.titleText = SearchQuerySettings.default.tagsKeyword + tag.name

        return cell
    }

    /// Returns the Prefix for a given note: We'll prepend the (Creation / Modification) Date, whenever we're in Search, and the Sort Option is relevant
    ///
    func prefixText(for note: Note) -> String? {
        guard case .searching = notesListController.state,
            let date = note.date(for: notesListController.sortMode)
            else {
                return nil
        }

        return DateFormatter.listDateFormatter.string(from: date)
    }
}


// MARK: - Table
//
extension SPNoteListViewController {
    @objc
    func reloadTableData() {
        tableView.reloadData()
        updateCurrentSelection()
    }

    @objc
    func updateCurrentSelection() {
        tableView.deselectSelectedRow()
        if let note = selectedNote, let indexPath = notesListController.indexPath(forObject: note) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    private func updateSelectedNoteBasedOnSelectedIndexPath() {
        selectedNote = tableView.indexPathForSelectedRow.flatMap { indexPath in
            notesListController.object(at: indexPath) as? Note
        }
    }

    open override func setEditing(_ editing: Bool, animated: Bool) {
        ensureTableViewEditingIsInSync()
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        refreshEditButtonTitle()
        refreshSelectAllLabels()

        tableView.deselectAllRows(inSection: .zero, animated: false)
        updateNavigationBar()

        configureNavigationToolbarButton()
        navigationController?.setToolbarHidden(!editing, animated: true)
        refreshListViewTitle()
        searchController.setEnabled(!editing)
    }

    private func ensureTableViewEditingIsInSync() {
        // If a swipe action is active, the tableView will already be set to isEditing == true
        // The edit button is still active while the swipe actions are active, if pressed
        // the VC and the tableview will get set to true, but since the tableView is already
        // editing nothind will happen.
        // This method ensures the tableview and VC are in sync when the edit button is tapped
        guard tableView.isEditing != isEditing else {
            return
        }
        tableView.setEditing(isEditing, animated: false)
    }

    private func refreshListViewTitle() {
        title = {
            guard isEditing else {
                return notesListController.filter.title
            }

            let count = tableView.indexPathsForSelectedRows?.count ?? .zero
            return count > 0 ? Localization.selectedTitle(with: count) : notesListController.filter.title
        }()
    }
}

// MARK: - Row Actions
//
private extension SPNoteListViewController {

    func contextActions(for note: Note) -> [UIContextualAction] {
        if note.deleted {
            return deletedContextActions(for: note)
        }

        return regularContextActions(for: note)
    }

    func deletedContextActions(for note: Note) -> [UIContextualAction] {

        let restoreAction = UIContextualAction(style: .normal, image: .image(name: .restore), backgroundColor: .simplenoteRestoreActionColor) { (_, _, completion) in
                SPObjectManager.shared().restoreNote(note)
                CSSearchableIndex.default().indexSearchableNote(note)
                completion(true)
            }
        restoreAction.accessibilityLabel = ActionTitle.restore

        let deleteAction = UIContextualAction(style: .destructive, image: .image(name: .trash), backgroundColor: .simplenoteDestructiveActionColor) { (_, _, completion) in
                SPTracker.trackListNoteDeleted()
                SPObjectManager.shared().permenentlyDeleteNote(note)
                completion(true)
            }
        deleteAction.accessibilityLabel = ActionTitle.delete

        return [restoreAction, deleteAction]
    }

    func regularContextActions(for note: Note) -> [UIContextualAction] {
        let pinImageName: UIImageName = note.pinned ? .unpin : .pin
        let pinActionTitle: String = note.pinned ? ActionTitle.unpin : ActionTitle.pin

        let trashAction = UIContextualAction(style: .destructive, title: nil, image: .image(name: .trash), backgroundColor: .simplenoteDestructiveActionColor) { [weak self] (_, _, completion) in
                self?.delete(note: note)
                NoticeController.shared.present(NoticeFactory.noteTrashed(onUndo: {
                    SPObjectManager.shared().restoreNote(note)
                    SPTracker.trackPreformedNoticeAction(ofType: .noteTrashed, noticeType: .undo)
                    self?.tableView.reloadData()
                }))
                SPTracker.trackPresentedNotice(ofType: .noteTrashed)
                completion(true)
        }
        trashAction.accessibilityLabel = ActionTitle.trash

        let pinAction = UIContextualAction(style: .normal, title: nil, image: .image(name: pinImageName), backgroundColor: .simplenoteSecondaryActionColor) { [weak self] (_, _, completion) in
                self?.togglePinnedState(note: note)
                completion(true)
            }
        pinAction.accessibilityLabel = pinActionTitle

        let copyAction = UIContextualAction(style: .normal, title: nil, image: .image(name: .link), backgroundColor: .simplenoteTertiaryActionColor) { [weak self] (_, _, completion) in
                self?.copyInternalLink(to: note)
                NoticeController.shared.present(NoticeFactory.linkCopied())
            SPTracker.trackPresentedNotice(ofType: .internalLinkCopied)
                completion(true)
            }
        copyAction.accessibilityLabel = ActionTitle.copyLink

        let shareAction = UIContextualAction(style: .normal, title: nil, image: .image(name: .share), backgroundColor: .simplenoteQuaternaryActionColor) { [weak self] (_, _, completion) in
                self?.share(note: note)
                completion(true)
            }
        shareAction.accessibilityLabel = ActionTitle.share


        return [trashAction, pinAction, copyAction, shareAction]
    }
}


// MARK: - UIMenu
//
@available(iOS 13.0, *)
private extension SPNoteListViewController {

    /// Invoked by the Long Press UITableView Mechanism (ex 3d Touch)
    ///
    func contextMenu(for note: Note, at indexPath: IndexPath) -> UIMenu {
        let copy = UIAction(title: ActionTitle.copyLink, image: .image(name: .link)) { [weak self] _ in
            self?.copyInternalLink(to: note)
            NoticeController.shared.present(NoticeFactory.linkCopied())
            SPTracker.trackPresentedNotice(ofType: .internalLinkCopied)
        }

        let share = UIAction(title: ActionTitle.share, image: .image(name: .share)) { [weak self] _ in
            self?.share(note: note)
        }

        let pinTitle = note.pinned ? ActionTitle.unpin : ActionTitle.pin
        let pin = UIAction(title: pinTitle, image: .image(name: .pin)) { [weak self] _ in
            self?.togglePinnedState(note: note)
        }

        let select = UIAction(title: ActionTitle.select, image: .image(name: .success)) { [weak self] _ in
            self?.setEditing(true, animated: true)
            self?.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self?.tableView.scrollToNearestSelectedRow(at: .none, animated: false)
            self?.refreshListViewTitle()
            self?.refreshTrashButton()
            self?.refreshSelectAllLabels()
        }
        if isSearchActive {
            select.attributes = .disabled
        }

        /// NOTE:
        /// iOS 13 exhibits a broken animation when performing a Delete OP from a ContextMenu.
        /// Since this appears to be fixed in iOS 14, quick workaround is: remove Delete from the Contextual Actions for iOS 13.
        ///
        /// Ref.: https://github.com/Automattic/simplenote-ios/pull/902/files
        ///
        guard #available(iOS 14.0, *) else {
            return UIMenu(title: "", children: [select, share, copy, pin])
        }

        let delete = UIAction(title: ActionTitle.delete, image: .image(name: .trash), attributes: .destructive) { [weak self] _ in
            self?.delete(note: note)
            NoticeController.shared.present(NoticeFactory.noteTrashed(onUndo: {
                SPObjectManager.shared().restoreNote(note)
                SPTracker.trackPreformedNoticeAction(ofType: .noteTrashed, noticeType: .undo)
                self?.tableView.reloadData()
            }))
            SPTracker.trackPresentedNotice(ofType: .noteTrashed)
        }

        return UIMenu(title: "", children: [select, share, copy, pin, delete])
    }
}


// MARK: - Services
//
private extension SPNoteListViewController {
    func delete(note: Note) {
        SPTracker.trackListNoteDeleted()
        SPObjectManager.shared().trashNote(note)
        CSSearchableIndex.default().deleteSearchableNote(note)
    }

    func copyInternalLink(to note: Note) {
        SPTracker.trackListCopiedInternalLink()
        UIPasteboard.general.copyInternalLink(to: note)
    }

    func togglePinnedState(note: Note) {
        SPTracker.trackListPinToggled()
        SPObjectManager.shared().updatePinnedState(!note.pinned, note: note)
    }

    func share(note: Note) {
        guard let _ = note.content, let activityController = UIActivityViewController(note: note) else {
            return
        }

        SPTracker.trackEditorNoteContentShared()

        guard UIDevice.sp_isPad(), let indexPath = notesListController.indexPath(forObject: note) else {
            present(activityController, animated: true, completion: nil)
            return
        }

        activityController.modalPresentationStyle = .popover

        let presentationController = activityController.popoverPresentationController
        presentationController?.permittedArrowDirections = .any
        presentationController?.sourceRect = tableView.rectForRow(at: indexPath)
        presentationController?.sourceView = tableView

        present(activityController, animated: true, completion: nil)
    }

    func previewingViewController(for note: Note) -> SPNoteEditorViewController {
        let editorViewController = EditorFactory.shared.build(with: note)
        editorViewController.isPreviewing = true
        editorViewController.update(withSearchQuery: searchQuery)

        return editorViewController
    }

    func delete(notes: [Note]) {
        for note in notes {
            delete(note: note)
        }

        NoticeController.shared.present(NoticeFactory.notesTrashed(notes, onUndo: {
            for note in notes {
                SPObjectManager.shared().restoreNote(note)
            }
            SPTracker.trackPreformedNoticeAction(ofType: .multipleNotesTrashed, noticeType: .undo)
        }))
        SPTracker.trackPresentedNotice(ofType: .multipleNotesTrashed)

        setEditing(false, animated: true)
    }
}


// MARK: - Services (Internal)
//
extension SPNoteListViewController {
    @objc
    func createNewNote() {
        SPTracker.trackListNoteCreated()

        // the editor view will create a note. Passing no note ensures that an emty note isn't added
        // to the FRC before the animation occurs
        tableView.setEditing(false, animated: false)
        open(nil, animated: true)
    }
}


// MARK: - Keyboard Handling
//
extension SPNoteListViewController {

    @objc(keyboardWillChangeFrame:)
    func keyboardWillChangeFrame(note: Notification) {

        guard let _ = view.window else {
            // No window means we aren't in the view hierarchy.
            // Asking UITableView to refresh layout when not in the view hierarcy results in console warnings.
            return
        }

        guard let keyboardFrame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        keyboardHeight = keyboardFrame.intersection(view.frame).height
        refreshTableViewBottomInsets(animated: true)
    }

    func refreshTableViewBottomInsets(animated: Bool = false) {
        let bottomInsets = bottomInsetsForTableView

        let updates = {
            self.tableView.contentInset.bottom = bottomInsets
            self.tableView.scrollIndicatorInsets.bottom = bottomInsets
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: UIKitConstants.animationShortDuration, animations: updates)
        } else {
            updates()
        }
    }

    var bottomInsetsForTableView: CGFloat {
        // Keyboard offScreen + Search Active: Seriously, consider the Search Bar
        guard keyboardHeight > .zero else {
            return .zero
        }

        // Keyboard onScreen: the SortBar falls below the keyboard
        return keyboardHeight
    }
}


// MARK: - Search Action Handlers
//
extension SPNoteListViewController {

    private var popoverPresenter: PopoverPresenter {
        let viewportProvider: () -> CGRect = { [weak self] in
            guard let self = self else {
                return .zero
            }

            let bounds = self.view.bounds.inset(by: self.view.safeAreaInsets)

            return self.view.convert(bounds, to: nil)
        }

        let presenter = PopoverPresenter(containerViewController: self, viewportProvider: viewportProvider)
        presenter.dismissOnInteractionWithPassthruView = true
        presenter.dismissOnContainerFrameChange = true
        presenter.centerContentRelativeToAnchor = view.frame.width > Constants.centeredSortPopoverThreshold
        return presenter
    }
}


// MARK: - Keyboard
//
extension SPNoteListViewController {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var keyCommands: [UIKeyCommand]? {
        var commands = tableCommands
        if isSearchActive {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(keyboardStopSearching)))

            // We add this shortcut only when search bar is first responder because when it's not we don't want to clear the search.
            // The shortcut that actually focuses on the searchbar is located in `SPSidebarContainerViewController`. This is done to make shortcut work from multiple screens
            if searchBar.isFirstResponder {
                commands.append(UIKeyCommand(input: "f", modifierFlags: [.command, .shift], action: #selector(keyboardStopSearching)))
            }
        }
        return commands
    }

    @objc
    private func keyboardStopSearching() {
        endSearching()
    }
}

// MARK: - Keyboard (List)
//
private extension SPNoteListViewController {
    var tableCommands: [UIKeyCommand] {
        var commands = [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyboardUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyboardDown)),
            UIKeyCommand(input: UIKeyCommand.inputReturn, modifierFlags: [], action: #selector(keyboardSelect))
        ]

        if isFirstResponder {
            commands.append(UIKeyCommand(input: UIKeyCommand.inputTrailingArrow, modifierFlags: [], action: #selector(keyboardSelect)))
        }

        return commands
    }

    @objc
    func keyboardUp() {
        navigatingUsingKeyboard = true
        tableView?.selectPrevRow()
        updateSelectedNoteBasedOnSelectedIndexPath()
    }

    @objc
    func keyboardDown() {
        navigatingUsingKeyboard = true
        tableView?.selectNextRow()
        updateSelectedNoteBasedOnSelectedIndexPath()
    }

    @objc
    func keyboardSelect() {
        navigatingUsingKeyboard = true
        tableView?.executeSelection()
    }
}


// MARK: - Private Types
//
private enum ActionTitle {
    static let cancel = NSLocalizedString("Cancel", comment: "Dismissing an interface")
    static let copyLink = NSLocalizedString("Copy Internal Link", comment: "Copies Link to a Note")
    static let trash = NSLocalizedString("Move to Trash", comment: "Deletes a note")
    static let pin = NSLocalizedString("Pin to Top", comment: "Pins a note")
    static let share = NSLocalizedString("Share...", comment: "Shares a note")
    static let unpin = NSLocalizedString("Unpin", comment: "Unpins a note")
    static let restore = NSLocalizedString("Restore Note", comment: "Restore a note from trash")
    static let delete = NSLocalizedString("Delete Note", comment: "Delete a note from trash")
    static let select = NSLocalizedString("Select", comment: "Select multiple notes at once")
}

private enum Constants {

    /// Section Header's Estimated Height
    ///
    static let estimatedHeightForHeaderInSection = CGFloat(30)

    /// Where do these insets come from?
    /// `For other subviews in your view hierarchy, the default layout margins are normally 8 points on each side`
    ///
    /// We're replicating the (old) view herarchy's behavior, in which the SearchBar would actually be contained within a view with 8pt margins on each side.
    /// This won't be required anymore *soon*, and it's just a temporary workaround.
    ///
    /// Ref. https://developer.apple.com/documentation/uikit/uiview/1622566-layoutmargins
    ///
    static let searchBarInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)

    static let searchEmptyStateTopMargin = CGFloat(128)

    static let centeredSortPopoverThreshold = CGFloat(500)
}

private enum Localization {

    enum EmptyState {
        static let allNotes = NSLocalizedString("Create your first note", comment: "Message shown in note list when no notes are in the current view")

        static let trash = NSLocalizedString("Your trash is empty", comment: "Message shown in note list when no notes are in the trash")

        static let untagged = NSLocalizedString("No untagged notes", comment: "Message shown in note list when no notes are untagged")


        static func tagged(with tag: String) -> String {
            return String(format: NSLocalizedString("No notes tagged “%@”", comment: "Message shown in note list when no notes are tagged with the provided tag. Parameter: %@ - tag"), tag)
        }

        static let searchTitle = NSLocalizedString("No Results", comment: "Message shown when no notes match a search string")

        static func searchAction(with searchTerm: String) -> String {
            return String(format: NSLocalizedString("Create a new note titled “%@”", comment: "Tappable message shown when no notes match a search string. Parameter: %@ - search term"), searchTerm)
        }
    }

    static func selectedTitle(with count: Int) -> String {
        let string = NSLocalizedString("%i Selected", comment: "Count of currently selected notes")
        return String(format: string, count)
    }

    static func selectAllLabel(deselect: Bool) -> String {
        let selectLabel = NSLocalizedString("Select All", comment: "Select all Button Label")
        let deselectLabel = NSLocalizedString("Deselect All", comment: "Deselect all Button Label")
        return deselect ? deselectLabel : selectLabel
    }

    static let selectAllAccessibilityHint = NSLocalizedString("Tap button to select or deselect all notes", comment: "Accessibility hint for the select/deselect all button")

    static let editTitle = NSLocalizedString("Edit", comment: "Edit button title")

    static let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
}
