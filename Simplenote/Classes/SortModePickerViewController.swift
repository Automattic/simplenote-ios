import UIKit

// MARK: - SortModePickerViewController
//
class SortModePickerViewController: UIViewController {
    @IBOutlet private weak var tableView: HuggableTableView! {
        didSet {
            tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
            tableView.separatorColor = .simplenoteDividerColor
            tableView.tableFooterView = UIView()
            tableView.alwaysBounceVertical = false
            tableView.backgroundColor = .clear
        }
    }

    private let data: [SortMode] = [
        .alphabeticallyAscending,
        .alphabeticallyDescending,
        .createdNewest,
        .createdOldest,
        .modifiedNewest,
        .modifiedOldest
    ]

    private let currentSelection: SortMode

    /// Called when row is selected
    ///
    var onSelectionCallback: ((SortMode) -> Void)?

    init(currentSelection: SortMode) {
        self.currentSelection = currentSelection
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
}

// MARK: - UITableViewDelegate
//
extension SortModePickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        onSelectionCallback?(data[indexPath.row])
    }
}

// MARK: - UITableViewDataSource
//
extension SortModePickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)

        let sortMode = data[indexPath.row]

        cell.accessoryType = sortMode == currentSelection ? .checkmark : .none
        cell.tintColor = .simplenoteTextColor

        cell.title = sortMode.description
        cell.hasClearBackground = true
        cell.separatorInset = .zero
        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        // "Drops" the last separator!
        .leastNonzeroMagnitude
    }
}
