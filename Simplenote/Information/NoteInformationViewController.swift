import UIKit
import SimplenoteFoundation

// MARK: - NoteInformationViewController
//
class NoteInformationViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var screenTitleLabel: UILabel!
    @IBOutlet private weak var dismissButton: UIButton!

    private var transitioningManager: UIViewControllerTransitioningDelegate?

    private let note: Note
    private var rows: [Row] = []

    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        reloadData()
    }

    private func setupTableView() {
        tableView.register(Value1TableViewCell.self, forCellReuseIdentifier: Value1TableViewCell.reuseIdentifier)
    }

    private func reloadData() {
        let metrics = NoteMetrics(note: note)

        rows = [
            .metric(title: NSLocalizedString("Modified", comment: "Note Modification Date"),
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.modifiedDate)),

            .metric(title: NSLocalizedString("Created", comment: "Note Creation Date"),
                    value: DateFormatter.dateTimeFormatter.string(from: metrics.creationDate)),

            .metric(title: NSLocalizedString("Words", comment: "Number of words in the note"),
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfWords)),

            .metric(title: NSLocalizedString("Characters", comment: "Number of characters in the note"),
                    value: NumberFormatter.decimalFormatter.string(for: metrics.numberOfChars))
        ]
    }
}

// MARK: - Handling button events
//
private extension NoteInformationViewController {
    @IBAction func handleTapOnDismissButton() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
//
extension NoteInformationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: - UITableViewDataSource
//
extension NoteInformationViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.row]

        switch row {
        case .metric(let title, let value):
            let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
            configure(cell: cell, withTitle: title, value: value)
            return cell
        }
    }

    private func configure(cell: Value1TableViewCell, withTitle title: String, value: String?) {
        cell.title = title
        cell.detailTextLabel?.text = value
    }
}

// MARK: - Presentation
//
extension NoteInformationViewController {

    /// Configure view controller to be presented as a card
    ///
    func configureToPresentAsCard() {
        let transitioningManager = SPCardTransitioningManager()
        self.transitioningManager = transitioningManager

        transitioningDelegate = transitioningManager
        modalPresentationStyle = .custom
    }
}

private enum Row {
    case metric(title: String, value: String?)
}
