import Foundation
import SimplenoteFoundation

// MARK: - TagListViewController
//
final class TagListViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var rightBorderView: UIView!
    @IBOutlet private weak var rightBorderWidthConstraint: NSLayoutConstraint!

    private lazy var tagsHeaderView: SPTagHeaderView = SPTagHeaderView.instantiateFromNib()

    private lazy var resultsController: ResultsController<Tag> = {
        let mainContext = SPAppDelegate.shared().managedObjectContext
        return ResultsController(viewContext: mainContext,
                                 sortedBy: sortDescriptors)
    }()

    private var renameTag: Tag?

    override var shouldAutorotate: Bool {
        return false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        configureTableHeaderView()
        configureRightBorderView()
        configureMenuController()
        startListeningToNotifications()

        refreshStyle()

        performFetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListeningToKeyboardNotifications()

        reloadTableView()
        startListeningForChanges()
        becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setEditing(false)

        stopListeningToKeyboardNotifications()
        stopListeningForChanges()

        resignFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshTableHeaderSize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        refreshTableHeaderSize()
    }
}


// MARK: - Configuration
//
private extension TagListViewController {
    func configureView() {
        view.backgroundColor = .simplenoteBackgroundColor
    }

    func configureTableView() {
        let sustainerView: SustainerView = SustainerView.instantiateFromNib()

        tableView.tableHeaderView = sustainerView
        tableView.register(TagListViewCell.loadNib(), forCellReuseIdentifier: TagListViewCell.reuseIdentifier)
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)

        tableView.separatorInsetReference = .fromAutomaticInsets
        tableView.automaticallyAdjustsScrollIndicatorInsets = false
    }

    func configureTableHeaderView() {
        tagsHeaderView.titleLabel.text = Localization.tags
        tagsHeaderView.titleLabel.font = .preferredFont(for: .title2, weight: .bold)

        let actionButton = tagsHeaderView.actionButton
        actionButton?.setTitle(Localization.edit, for: .normal)
        actionButton?.addTarget(self, action: #selector(editTagsTap), for: .touchUpInside)
    }

    func configureRightBorderView() {
        rightBorderWidthConstraint.constant = UIScreen.main.pointToPixelRatio
    }

    func configureMenuController() {
        let renameSelector = sel_registerName("rename:")
        let renameItem = UIMenuItem(title: Localization.rename, action: renameSelector)

        UIMenuController.shared.menuItems = [renameItem]
        UIMenuController.shared.update()
    }
}

// MARK: - Notifications
//
private extension TagListViewController {
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(menuDidChangeVisibility), name: UIMenuController.didShowMenuNotification, object: nil)
        nc.addObserver(self, selector: #selector(menuDidChangeVisibility), name: UIMenuController.didHideMenuNotification, object: nil)
        nc.addObserver(self, selector: #selector(tagsSortOrderWasUpdated), name: NSNotification.Name.SPAlphabeticalTagSortPreferenceChanged, object: nil)
        nc.addObserver(self, selector: #selector(themeDidChange), name: NSNotification.Name.SPSimplenoteThemeChanged, object: nil)
    }

    func startListeningToKeyboardNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func stopListeningToKeyboardNotifications() {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

// MARK: - Notifications
//
private extension TagListViewController {
    @objc
    func themeDidChange() {
        refreshStyle()
    }

    @objc
    func menuDidChangeVisibility() {
        tableView.allowsSelection = !UIMenuController.shared.isMenuVisible
    }

    @objc
    func tagsSortOrderWasUpdated() {
        refreshSortDescriptorsAndPerformFetch()
    }
}

// MARK: - Style
//
private extension TagListViewController {
    func refreshStyle() {
        rightBorderView.backgroundColor = .simplenoteDividerColor
        tagsHeaderView.refreshStyle()
        tableView.applySimplenotePlainStyle()
        reloadTableView()
    }
}

// MARK: - Button actions
//
private extension TagListViewController {
    @objc
    func editTagsTap() {
        let newState = !isEditing
        if newState {
            SPTracker.trackTagEditorAccessed()
        }

        setEditing(newState)
    }
}

// MARK: - Helper Methods
//
private extension TagListViewController {
    func cell(for tag: Tag) -> TagListViewCell? {
        guard let indexPath = indexPath(for: tag) else {
            return nil
        }

        return tableView.cellForRow(at: indexPath) as? TagListViewCell
    }

    func indexPath(for tag: Tag) -> IndexPath? {
        guard let indexPath = resultsController.indexPath(forObject: tag) else {
            return nil
        }

        return IndexPath(row: indexPath.row, section: Section.tags.rawValue)
    }

    func tag(at indexPath: IndexPath) -> Tag? {
        guard indexPath.row < numberOfTags
                && Section(rawValue: indexPath.section) == .tags else {
            return nil
        }

        // Our FRC has just one section!
        let indexPath = IndexPath(row: indexPath.row, section: 0)
        return resultsController.object(at: indexPath)
    }

    var numberOfTags: Int {
        return resultsController.numberOfObjects
    }
}

// MARK: - Table
//
extension TagListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if Section(rawValue: section) == .tags {
            return UITableView.automaticDimension
        }

        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if Section(rawValue: section) == .tags {
            return tagsHeaderView
        }

        return nil
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let isTagRow = Section(rawValue: indexPath.section) == .tags
        let isSortEnabled = UserDefaults.standard.bool(forKey: SPAlphabeticalTagSortPref)

        return isTagRow && !isSortEnabled
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfTags == 0 ? 1 : Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }

        switch section {
        case .system:
            return SystemRow.allCases.count
        case .tags:
            return numberOfTags
        case .bottom:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {
        case .system:
            let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
            configureSystemCell(cell, at: indexPath)
            return cell
        case .tags:
            let cell = tableView.dequeueReusableCell(ofType: TagListViewCell.self, for: indexPath)
            configureTagCell(cell, at: indexPath)
            return cell
        case .bottom:
            let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
            configureBottomCell(cell, at: indexPath)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.adjustSeparatorWidth(width: .full)
    }

    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        let isTagRow = Section(rawValue: indexPath.section) == .tags
        if isTagRow {
            SPTracker.trackTagCellPressed()
        }

        return isTagRow
    }

    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(at: indexPath, isTraversing: false)
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard Section(rawValue: sourceIndexPath.section) == .tags
                && Section(rawValue: destinationIndexPath.section) == .tags else {
            return
        }

        stopListeningForChanges()
        SPObjectManager.shared().moveTag(from: sourceIndexPath.row,
                                         to: destinationIndexPath.row)
        startListeningForChanges()
    }

    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard Section(rawValue: sourceIndexPath.section) == .tags
                && Section(rawValue: proposedDestinationIndexPath.section) == .tags else {
            return sourceIndexPath
        }

        return proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func reloadTableView() {
        tableView.reloadData()
        updateCurrentSelection()
    }
}

// MARK: - Cell Setup
//
private extension TagListViewController {

    func configureSystemCell(_ cell: Value1TableViewCell, at indexPath: IndexPath) {
        guard let row = SystemRow(rawValue: indexPath.row) else {
            return
        }

        cell.hasClearBackground = true
        cell.imageTintColor = .simplenoteTintColor

        switch row {
        case .allNotes:
            cell.title = Localization.allNotes
            cell.imageView?.image = .image(name: .allNotes)
            cell.accessibilityIdentifier = "all-notes"
        case .trash:
            cell.title = Localization.trash
            cell.imageView?.image = .image(name: .trash)
            cell.accessibilityIdentifier = nil
        case .settings:
            cell.title = Localization.settings
            cell.imageView?.image = .image(name: .settings)
            cell.accessibilityIdentifier = "settings"
        }
    }

    func configureTagCell(_ cell: TagListViewCell, at indexPath: IndexPath) {
        let tagName = tag(at: indexPath)?.name

        cell.textField.text = tagName
        cell.delegate = self
    }

    func configureBottomCell(_ cell: Value1TableViewCell, at indexPath: IndexPath) {
        cell.title = Localization.untaggedNotes
        cell.imageView?.image = .image(name: .untagged)
        cell.accessibilityIdentifier = nil

        cell.hasClearBackground = true
        cell.imageTintColor = .simplenoteTintColor
    }
}

// MARK: - Selection
//
private extension TagListViewController {
    func updateCurrentSelection() {
        tableView.selectRow(at: currentSelection, animated: false, scrollPosition: .none)
    }

    var currentSelection: IndexPath? {
        let filter = NotesListFilter(selectedTag: SPAppDelegate.shared().selectedTag)
        switch filter {
        case .everything:
            return IndexPath(row: SystemRow.allNotes.rawValue,
                             section: Section.system.rawValue)
        case .deleted:
            return IndexPath(row: SystemRow.trash.rawValue,
                             section: Section.system.rawValue)
        case .untagged:
            return IndexPath(row: 0,
                             section: Section.bottom.rawValue)
        case .tag(let tagName):
            guard let index = resultsController.fetchedObjects.firstIndex(where: {
                $0.name == tagName
            }) else {
                return nil
            }

            return IndexPath(row: index,
                             section: Section.tags.rawValue)
        }
    }
}

// MARK: - Row Press Handlers
//
private extension TagListViewController {

    func didSelectRow(at indexPath: IndexPath, isTraversing: Bool) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }

        switch section {
        case .system:
            didSelectSystemRow(at: indexPath, isTraversing: isTraversing)
        case .tags:
            didSelectTag(at: indexPath, isTraversing: isTraversing)
        case .bottom:
            didSelectBottomRow(at: indexPath, isTraversing: isTraversing)
        }
    }

    func didSelectSystemRow(at indexPath: IndexPath, isTraversing: Bool) {
        guard let row = SystemRow(rawValue: indexPath.row) else {
            return
        }

        if !isTraversing {
            setEditing(false)
        }

        switch row {
        case .allNotes:
            openNoteListForTagName(nil, isTraversing: isTraversing)
        case .trash:
            SPTracker.trackTrashViewed()
            openNoteListForTagName(kSimplenoteTrashKey, isTraversing: isTraversing)
        case .settings:
            if isTraversing {
                return
            }
            updateCurrentSelection()
            SPAppDelegate.shared().presentSettingsViewController()
        }
    }

    func didSelectTag(at indexPath: IndexPath, isTraversing: Bool) {
        guard let tag = tag(at: indexPath) else {
            return
        }

        if isEditing && !isTraversing {
            SPTracker.trackTagRowRenamed()
            renameTag(tag)
        } else {
            SPTracker.trackListTagViewed()
            openNoteListForTagName(tag.name, isTraversing: isTraversing)
        }
    }

    func didSelectBottomRow(at indexPath: IndexPath, isTraversing: Bool) {
        if !isTraversing {
            setEditing(false)
        }

        SPTracker.trackListUntaggedViewed()
        openNoteListForTagName(kSimplenoteUntaggedKey, isTraversing: isTraversing)
    }
}

// MARK: - TagListViewCellDelegate
//
extension TagListViewController: TagListViewCellDelegate {

    func tagListViewCellShouldRenameTag(_ cell: TagListViewCell) {
        SPTracker.trackTagMenuRenamed()

        guard let indexPath = tableView.indexPath(for: cell),
              let tag = tag(at: indexPath) else {
            return
        }

        renameTag(tag)
    }

    func tagListViewCellShouldDeleteTag(_ cell: TagListViewCell, source: TagListViewCellDeletionSource) {
        guard let indexPath = tableView.indexPath(for: cell), let tag = tag(at: indexPath) else {
            return
        }

        let alertController = UIAlertController(title: Localization.TagDeletionConfirmation.title(with: tag.name ?? ""),
                                                message: nil,
                                                preferredStyle: .actionSheet)

        alertController.addDestructiveActionWithTitle(Localization.TagDeletionConfirmation.confirmationButton) { (_) in
            switch source {
            case .accessory:
                SPTracker.trackTagRowDeleted()
            case .menu:
                SPTracker.trackTagMenuDeleted()
            }

            self.removeTag(at: indexPath)
        }

        alertController.addCancelActionWithTitle(Localization.TagDeletionConfirmation.cancellationButton)

        alertController.popoverPresentationController?.sourceRect = cell.bounds
        alertController.popoverPresentationController?.sourceView = cell
        alertController.popoverPresentationController?.permittedArrowDirections = .any

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Helper Methods
//
private extension TagListViewController {
    func setEditing(_ editing: Bool) {
        // Note: Neither super.setEditing nor tableView.setEditing will resign the first responder.
        if !editing {
            view.endEditing(true)
        }

        super.setEditing(editing, animated: true)
        tableView.setEditing(editing, animated: true)
        refreshEditTagsButton(isEditing: editing)
        updateCurrentSelection()
    }

    func refreshEditTagsButton(isEditing: Bool) {
        let title = isEditing ? Localization.done : Localization.edit
        tagsHeaderView.actionButton.setTitle(title, for: .normal)
    }

    func refreshTableHeaderSize() {
        guard let headerView = tableView.tableHeaderView as? SustainerView else {
            return
        }

        headerView.preferredWidth = tableView.frame.width - view.safeAreaInsets.left
        headerView.adjustSizeForCompressedLayout()

        tableView.tableHeaderView = headerView
    }

    func openNoteListForTagName(_ tagName: String?, isTraversing: Bool) {
        let appDelegate = SPAppDelegate.shared()
        appDelegate.selectedTag = tagName
        if !isTraversing {
            appDelegate.sidebarViewController.hideSidebar(withAnimation: true)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
//
extension TagListViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Tag Actions
//
private extension TagListViewController {
    func removeTag(at indexPath: IndexPath) {
        guard let tag = tag(at: indexPath) else {
            return
        }

        let appDelegate = SPAppDelegate.shared()
        if appDelegate.selectedTag == tag.name {
            appDelegate.selectedTag = nil
        }

        SPObjectManager.shared().removeTag(tag)
    }

    func renameTag(_ tag: Tag) {
        if let renameTag = renameTag {
            cell(for: renameTag)?.textField.endEditing(true)
        }

        renameTag = tag

        guard let tagCell = cell(for: tag) else {
            return
        }

        tagCell.textField.isEnabled = true
        tagCell.textField.delegate = self
        tagCell.textField.becomeFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
//
extension TagListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text ?? "")
        guard let range = Range(range, in: text) else {
            return true
        }

        let validator = TagTextFieldInputValidator()
        let result = validator.validateInput(originalText: text, range: range, replacement: string)
        switch result {
        case .valid:
            return true
        case .endingWithDisallowedCharacter(let text):
            textField.text = text
            textField.endEditing(true)
            return false
        case .invalid:
            return false
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let renameTag = renameTag else {
            return
        }

        self.renameTag = nil

        if isEditing {
            updateCurrentSelection()
        }

        textField.isEnabled = false
        textField.delegate = nil

        let originalTagName = renameTag.name
        let newTagName = textField.text ?? ""

        // see if tag already exists, if not rename. If it does, revert back to original name
        let shouldRenameTag = !SPObjectManager.shared().tagExists(newTagName)

        if shouldRenameTag {
            SPObjectManager.shared().editTag(renameTag, title: newTagName)

            let appDelegate = SPAppDelegate.shared()
            if appDelegate.selectedTag == originalTagName {
                appDelegate.selectedTag = newTagName
            }
        } else {
            textField.text = originalTagName
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Results Controller
//
private extension TagListViewController {
    var sortDescriptors: [NSSortDescriptor] {
        let isAlphaSort = UserDefaults.standard.bool(forKey: SPAlphabeticalTagSortPref)
        let sortDescriptor: NSSortDescriptor
        if isAlphaSort {
            sortDescriptor = NSSortDescriptor(
                key: "name",
                ascending: true,
                selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        } else {
            sortDescriptor = NSSortDescriptor(key: "index", ascending: true)
        }

        return [sortDescriptor]
    }

    func performFetch() {
        try? resultsController.performFetch()
        reloadTableView()
    }

    func refreshSortDescriptorsAndPerformFetch() {
        resultsController.sortDescriptors = sortDescriptors
        performFetch()
    }

    func startListeningForChanges() {
        resultsController.onDidChangeContent = { [weak self] (sectionsChangeset, objectsChangeset) in
            guard let self = self else {
                return
            }

            guard self.tableView.window != nil else {
                return
            }

            // Reload if number of sections is different
            // Results controller supports only tags section. We show/hide tags section based on the number of tags®
            guard self.tableView.numberOfSections == self.numberOfSections(in: self.tableView) else {
                self.setEditing(false)
                self.reloadTableView()
                return
            }

            // If the change includes deleting the tag that is currently being edited
            // remove the reselect rename tag, disable editing and reload tableView
            if let renameTag = self.renameTag, !self.resultsController.fetchedObjects.contains(renameTag) {
                self.renameTag = nil
                self.setEditing(false)
                self.reloadTableView()
                return
            }

            self.reloadTable(with: sectionsChangeset.transposed(toSection: Section.tags.rawValue),
                             objectsChangeset: objectsChangeset.transposed(toSection: Section.tags.rawValue))
        }
    }

    func stopListeningForChanges() {
        resultsController.onDidChangeContent = nil
    }

    func reloadTable(with sectionsChangeset: ResultsSectionsChangeset, objectsChangeset: ResultsObjectsChangeset) {
        self.tableView.performBatchUpdates({
            // Disable animation for row updates
            let animations = ResultsTableAnimations(delete: .fade, insert: .fade, move: .fade, update: .none)
            self.tableView.performChanges(sectionsChangeset: sectionsChangeset,
                                          objectsChangeset: objectsChangeset,
                                          animations: animations)
        }, completion: nil)
        updateCurrentSelection()
    }
}

// MARK: - KeyboardNotifications
//
private extension TagListViewController {
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0

        var contentInsets = tableView.contentInset
        var scrollInsets = tableView.verticalScrollIndicatorInsets
        let keyboardHeight = min(keyboardFrame.size.height, keyboardFrame.size.width)

        contentInsets.bottom = keyboardHeight
        scrollInsets.bottom = keyboardHeight

        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.tableView.contentInset = contentInsets
            self.tableView.verticalScrollIndicatorInsets = scrollInsets
        })
    }

    @objc
    func keyboardWillHide(_ notification: NSNotification) {
        var contentInsets = tableView.contentInset
        contentInsets.bottom = view.safeAreaInsets.bottom

        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0

        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.tableView.contentInset = contentInsets
            self.tableView.scrollIndicatorInsets = .zero
        })
    }
}

// MARK: - Keyboard Support
//
extension TagListViewController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        guard isFirstResponder else {
            return nil
        }

        var commands = [
            UIKeyCommand(input: UIKeyCommand.inputTrailingArrow, modifierFlags: [], action: #selector(keyboardHideSidebar))
        ]
        commands.append(contentsOf: tableCommands)

        return commands
    }

    @objc
    private func keyboardHideSidebar() {
        let appDelegate = SPAppDelegate.shared()
        appDelegate.sidebarViewController.hideSidebar(withAnimation: true)
    }
}

// MARK: - Keyboard support (List)
//
private extension TagListViewController {
    var tableCommands: [UIKeyCommand] {
        [
            UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(keyboardUp)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(keyboardDown)),
            UIKeyCommand(input: "\r", modifierFlags: [], action: #selector(keyboardSelect))
        ]
    }

    @objc
    func keyboardUp() {
        tableView?.selectPrevRow()
        updateSelectionWhileTraversing()
    }

    @objc
    func keyboardDown() {
        tableView?.selectNextRow()
        updateSelectionWhileTraversing()
    }

    @objc
    func keyboardSelect() {
        tableView?.executeSelection()
    }

    func updateSelectionWhileTraversing() {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }

        // Skip for settings
        if indexPath.section == Section.system.rawValue && indexPath.row == SystemRow.settings.rawValue {
            return
        }

        didSelectRow(at: indexPath, isTraversing: true)
    }
}

// MARK: - Section enum
//
private enum Section: Int, CaseIterable {
    case system
    case tags
    case bottom
}

// MARK: - System Row enum
//
private enum SystemRow: Int, CaseIterable {
    case allNotes
    case trash
    case settings
}

// MARK: - Constants
//
private struct Constants {
    static let tagListBatchSize = 20
}

// MARK: - Localization
//
private struct Localization {
    static let edit = NSLocalizedString("Edit", comment: "Edit Tags Action: Visible in the Tags List")
    static let rename = NSLocalizedString("Rename", comment: "Rename a tag")
    static let done = NSLocalizedString("Done", comment: "Done editing tags")

    static let allNotes = NSLocalizedString("All Notes", comment: "All Notes filter button")
    static let trash = NSLocalizedString("Trash", comment: "Trash filter button")
    static let settings = NSLocalizedString("Settings", comment: "Settings button")

    static let tags = NSLocalizedString("Tags", comment: "Tags List Header")
    static let untaggedNotes = NSLocalizedString("Untagged Notes", comment: "Allows selecting notes with no tags")

    struct TagDeletionConfirmation {
        static func title(with tagName: String) -> String {
            let template = NSLocalizedString("Are you sure you want to delete \"%1$@\"?", comment: "Title of deletion confirmation message for a tag. Parameters: %1$@ - tag name")
            return String(format: template, tagName)
        }

        static let confirmationButton = NSLocalizedString("Delete Tag", comment: "Confirmation button of deletion confirmation message for a tag.")
        static let cancellationButton = NSLocalizedString("Cancel", comment: "Cancellation button of deletion confirmation message for a tag.")
    }
}
