import Foundation
import UIKit


// MARK: - SPSearchResultsViewController
//
class SPSearchResultsViewController: UIViewController, SPSearchControllerResults {

    /// Results TableView
    ///
    @IBOutlet private weak var tableView: UITableView!

    /// Bottom Bar: Background
    ///
    @IBOutlet private weak var sortByBackgroundView: SPBlurEffectView!

    /// Bottom Bar: Sort By Title
    ///
    @IBOutlet private weak var sortByTitleLabel: UILabel!

    /// Bottom Bar: Sort By Description
    ///
    @IBOutlet private weak var sortByDescriptionLabel: UILabel!

    /// Bottom Bar: Sort Order Button
    ///
    @IBOutlet private weak var sortOrderButton: UIButton!

    /// Haptics!
    ///
    private let feedbackGenerator = UIImpactFeedbackGenerator()

    /// Active Sorting Mode
    ///
    private var sortMode: SortMode {
        get {
            return resultsController.sortMode
        }
        set {
            resultsController.sortMode = newValue
            refreshSortDescriptionLabel()
        }
    }

    /// Main CoreData Context
    ///
    private var mainContext: NSManagedObjectContext {
        SPAppDelegate.shared().managedObjectContext
    }

    /// Results Controller
    ///
    private lazy var resultsController: SPSearchResultsController = {
        SPSearchResultsController(mainContext: mainContext)
    }()

    /// Additional bottom Inset: Meant to keep the keyboard's height!
    ///
    private var additionalBottomInset = CGFloat.zero

    /// SearchController: Expected to be set externally
    ///
    weak var searchController: SPSearchController?


    // MARK: - View Lifecycle

    deinit {
        removeKeyboardObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureBottomBar()
        configureResultsController()
        refreshSortDescriptionLabel()
        addKeyboardObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshStyle()
        refreshRowHeight()
        configureFeedbackGenerator()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBottomInsets()
    }
}


// MARK: - Interface Initialization
//
extension SPSearchResultsViewController {

    /// Resets the internal state for reuse:
    ///     - Search Keyword will be neutralized
    ///     - TableView's Scroll position will be moved to the top
    ///
    @objc
    func reset() {
        tableView.scrollToTop(animated: false)
        updateSearchResults(keyword: String())
    }

    /// Updates the Search Results to match a given keyword
    ///
    @objc
    func updateSearchResults(keyword: String) {
        // Note: Async, otherwise the UI won't feel snappy!
        DispatchQueue.main.async {
            self.resultsController.keyword = keyword
        }
    }
}


// MARK: - Initialization Helpers
//
private extension SPSearchResultsViewController {

    /// Sets up the FRC
    ///
    func configureResultsController() {
        resultsController.onDidChange = { [weak self] in
            self?.tableView.reloadData()
        }

        resultsController.performFetch()
    }

    /// Sets up the TableView
    ///
    func configureTableView() {
        tableView.register(SPNoteTableViewCell.loadNib(), forCellReuseIdentifier: SPNoteTableViewCell.reuseIdentifier)
        tableView.tableFooterView = UIView()
    }

    /// Sets up the Bottom Sort Order Bar
    ///
    func configureBottomBar() {
        sortByTitleLabel.text = NSLocalizedString("Sort by:", comment: "Sort By component title")
    }

    /// Sets up the Feedback Generator
    ///
    func configureFeedbackGenerator() {
        feedbackGenerator.prepare()
    }

    /// Refreshes the UI Style (iOS <13 DarkMode Support)
    ///
    func refreshStyle() {
        view.backgroundColor = .simplenoteBackgroundColor

        sortOrderButton.tintColor = .simplenoteBlue50Color
        sortByTitleLabel.textColor = .simplenoteNoteHeadlineColor
        sortByDescriptionLabel.textColor = .simplenoteBlue50Color

        tableView.applySimplenotePlainStyle()
    }

    /// Recalculates the TableView's Row Height
    ///
    func refreshRowHeight() {
        tableView.rowHeight = SPNoteTableViewCell.cellHeight
    }

    /// Updates the Sort Description Label
    ///
    func refreshSortDescriptionLabel() {
        sortByDescriptionLabel.text = sortMode.description
    }
}


// MARK: - UITableViewDataSource Methods
//
extension SPSearchResultsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        resultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        resultsController.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SPNoteTableViewCell.reuseIdentifier, for: indexPath) as? SPNoteTableViewCell else {
            fatalError()
        }

        configure(cell: cell, at: indexPath)

        return cell
    }
}


// MARK: - UITableViewDelegate Methods
//
extension SPSearchResultsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentEditor(note: note(at: indexPath), keyword: resultsController.keyword)

        SPTracker.trackListNoteOpened()
    }
}


// MARK: - UIScrollViewDelegate Methods
//
extension SPSearchResultsViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let searchBar = searchController?.searchBar, searchBar.isFirstResponder else {
            return
        }

        searchBar.resignFirstResponder()
    }
}


// MARK: - Private Methods
//
private extension SPSearchResultsViewController {

    /// Sets up a given NoteTableViewCell to display the specified Note
    ///
    func configure(cell: SPNoteTableViewCell, at indexPath: IndexPath) {
        let note = self.note(at: indexPath)

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

        guard resultsController.keyword.count > 0 else {
            return
        }

        cell.highlightSubstrings(matching: resultsController.keyword, color: .simplenoteTintColor)
    }

    /// Returns the Note at a given IndexPath
    ///
    func note(at indexPath: IndexPath) -> Note {
        resultsController.object(at: indexPath)
    }

    func presentEditor(note: Note, keyword: String) {
        let editorViewController = SPNoteEditorViewController()
        editorViewController.update(note)
        editorViewController.searchString = keyword

        /// We're sharing the navigationController with our container VC (expected to be NoteListViewController). Let's disable any custom anymations!
        navigationController?.delegate = nil
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}


// MARK: - Action Handlers
//
extension SPSearchResultsViewController {

    @IBAction
    func sortOrderWasPressed() {
        feedbackGenerator.impactOccurred()
        sortMode = sortMode.inverse
    }

    @IBAction
    func sortModeWasPressed() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        for mode in [SortMode.alphabeticallyAscending, .createdNewest, .modifiedNewest] {
            alertController.addDefaultActionWithTitle(mode.kind) { _ in
                self.sortMode = mode
            }
        }

        let cancelText = NSLocalizedString("Cancel", comment: "")
        alertController.addCancelActionWithTitle(cancelText)

        feedbackGenerator.impactOccurred()
        present(alertController, animated: true, completion: nil)
    }
}


// MARK: - KeyboardObservable Conformance
//
extension SPSearchResultsViewController: KeyboardObservable {

    func keyboardWillShow(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        guard let endFrame = endFrame else {
            return
        }

        additionalBottomInset = min(endFrame.height, endFrame.width)
        refreshBottomInsets()
    }

    func keyboardWillHide(beginFrame: CGRect?, endFrame: CGRect?, animationDuration: TimeInterval?, animationCurve: UInt?) {
        additionalBottomInset = .zero
        refreshBottomInsets()
    }

    func refreshBottomInsets() {
        let bottomPaddingY = view.frame.height - sortByBackgroundView.frame.origin.y - view.safeAreaInsets.bottom + additionalBottomInset

        tableView.contentInset.bottom = bottomPaddingY
        tableView.scrollIndicatorInsets.bottom = bottomPaddingY
    }
}
