import UIKit


// MARK: - NoteEditorTagSuggestionsViewController
//
class NoteEditorTagSuggestionsViewController: UIViewController {
    @IBOutlet private weak var tableView: HuggableTableView! {
        didSet {
            tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
            tableView.separatorColor = .simplenoteDividerColor
            tableView.tableFooterView = UIView()
            tableView.alwaysBounceVertical = false

            tableView.maxNumberOfVisibleRows = Metrics.maxNumberOfVisibleRows
        }
    }

    private let note: Note
    private let objectManager = SPObjectManager.shared()

    private var data: [String] = []

    /// Called when row is selected
    ///
    var onSelectionCallback: ((String) -> Void)?

    /// Is empty
    ///
    var isEmpty: Bool {
        return data.isEmpty
    }

    /// Init
    ///
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Update with keywords. Tags containing keywords that are not already in the note will be suggested
    ///
    func update(with keywords: String?) {
        let keywords = (keywords ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keywords.isEmpty else {
            reload(with: [])
            return
        }

        let tags = objectManager.tags()
            .filter { tag in
                !note.hasTag(tag.name) && tag.name.range(of: keywords, options: [.caseInsensitive, .diacriticInsensitive]) != nil
            }
            .compactMap { tag in
                tag.name
            }

        reload(with: tags)
    }

    private func reload(with data: [String]) {
        self.data = data
        // Can be called before view is loaded
        tableView?.reloadData()
    }
}


// MARK: - UITableViewDelegate
//
extension NoteEditorTagSuggestionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onSelectionCallback?(data[indexPath.row])
    }
}


// MARK: - UITableViewDataSource
//
extension NoteEditorTagSuggestionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.title = data[indexPath.row]
        cell.backgroundColor = .clear
        cell.separatorInset = .zero
        return cell
    }
}


// MARK: - Metrics
//
private struct Metrics {
    static let maxNumberOfVisibleRows: CGFloat = 3.5
}
