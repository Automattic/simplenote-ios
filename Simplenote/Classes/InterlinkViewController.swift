import Foundation
import UIKit
import SimplenoteFoundation


// MARK: - InterlinkViewController
//
class InterlinkViewController: UIViewController {

    /// Autocomplete TableView
    ///
    @IBOutlet private var tableView: UITableView!

    /// Main Context
    ///
    private var mainContext: NSManagedObjectContext {
        SPAppDelegate.shared().managedObjectContext
    }

    /// ResultsController: In charge of CoreData Queries!
    ///
    private lazy var resultsController: ResultsController<Note> = {
        return ResultsController<Note>(viewContext: mainContext, sortedBy: [
            NSSortDescriptor(keyPath: \Note.content, ascending: true)
        ])
    }()


    /// In-Memory Filtered Notes
    /// -   Our Storage does not split `Title / Body`. Filtering by keywords in the title require a NSPredicate + Block
    /// -   The above is awfully underperformant.
    /// -   Most efficient approach code wise / speed involves simply keeping a FRC instance, and filtering it as needed
    ///
    private var filteredNotes = [Note]()

    /// Closure to be executed whenever a Note is selected. The Interlink URL will be passed along.
    ///
    var onInsertInterlink: ((String) -> Void)?


    // MARK: - Overridden API(s)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupResultsController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}


// MARK: - Public API(s)
//
extension InterlinkViewController {

    func positionView(around range: Range<String.Index>, in textView: UITextView) {
// TODO: Properly Implement Me!
        let locationInView = textView.locationInSuperviewForText(in: range)
        view.frame.origin = locationInView.origin
    }
}


// MARK: - Search API
//
extension InterlinkViewController {

    /// Refreshes the Autocomplete Results. Returns `true` when there are visible rows.
    /// - Important:
    ///     By design, whenever there are no results we won't be refreshing the TableView. Instead, we'll stick to the "old results".
    ///     This way we get to avoid the awkward visual effect of "empty autocomplete view"
    ///
    func refreshInterlinks(for keyword: String, excluding excludedID: NSManagedObjectID?) -> Bool {
        filteredNotes = filterNotes(resultsController.fetchedObjects, byTitleKeyword: keyword, excluding: excludedID)
        let displaysRows = filteredNotes.count > .zero

        if displaysRows {
            refreshTableViewIfNeeded()
        }

        return displaysRows
    }
}


// MARK: - Setup!
//
private extension InterlinkViewController {

    func setupResultsController() {
        resultsController.predicate = NSPredicate.predicateForNotes(deleted: false)
        try? resultsController.performFetch()
    }

    func setupTableView() {
        tableView.applySimplenotePlainStyle()
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
    }
}


// MARK: - Filtering
//
private extension InterlinkViewController {

    /// Filters a collection of notes by their Title contents, excluding a specific Object ID.
    ///
    /// - Important: Why do we perform an *in memory* filtering?
    ///     - CoreData's SQLite store does not support block based predicates
    ///     - RegExes aren't diacritic + case insensitve friendly
    ///     - It's easier and anyone can follow along!
    ///
    func filterNotes(_ notes: [Note], byTitleKeyword keyword: String, excluding excludedID: NSManagedObjectID?, limit: Int = Settings.maximumNumberOfResults) -> [Note] {
        var output = [Note]()
        let normalizedKeyword = keyword.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)

        for note in notes where note.objectID != excludedID {
            note.ensurePreviewStringsAreAvailable()
            guard let normalizedTitle = note.titlePreview?.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil),
                  normalizedTitle.contains(normalizedKeyword)
            else {
                continue
            }

            output.append(note)

            if output.count >= limit {
                break
            }
        }

        return output
    }
}


// MARK: - Private API(s)
//
private extension InterlinkViewController {

    func noteAtIndexPath(_ indexPath: IndexPath) -> Note {
        filteredNotes[indexPath.row]
    }

    func performInterlinkInsert(for note: Note) {
        guard let markdownInterlink = note.markdownInternalLink else {
            return
        }

        onInsertInterlink?(markdownInterlink)
    }

    func refreshTableViewIfNeeded() {
        guard isViewLoaded else {
            return
        }

        tableView.reloadData()
    }
}


// MARK: - UITableViewDataSource
//
extension InterlinkViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredNotes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = noteAtIndexPath(indexPath)
        note.ensurePreviewStringsAreAvailable()

        let tableViewCell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        tableViewCell.title = note.titlePreview
        tableViewCell.backgroundColor = .clear
        return tableViewCell
    }
}


// MARK: - UITableViewDelegate
//
extension InterlinkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = noteAtIndexPath(indexPath)
        performInterlinkInsert(for: note)
    }
}


// MARK: - Settings!
//
private enum Settings {
    static let maximumNumberOfResults = 15
}
