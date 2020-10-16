import Foundation
import UIKit


// MARK: - OptionsViewController
//
class OptionsViewController: UIViewController {

    /// Options TableView
    ///
    @IBOutlet private var tableView: UITableView!

    /// Sections onScreen
    ///
    private let sections: [Section] = [
        Section(rows: [.pinToTop, .markdown, .copyInternalURL, .share, .history]),
        Section(rows: [.publish, .copyPublicURL]),
        Section(rows: [.collaborate]),
        Section(rows: [.trash])
    ]

    /// Note for which we'll render the current Options
    ///
    let note: Note


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

    func refreshPreferredSize() {
        preferredContentSize = tableView.contentSize
    }

    func refreshStyle() {
        view.backgroundColor = .simplenoteTableViewBackgroundColor
        tableView.applySimplenoteGroupedStyle()
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
        // TODO: Implement Me!
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
        return cell
    }

    func dequeueMarkdownCell(from tableView: UITableView, at indexPath: IndexPath) -> SwitchTableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: SwitchTableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .note)
        cell.title = NSLocalizedString("Markdown", comment: "Toggles the Markdown State")
        cell.enabledAccessibilityHint = NSLocalizedString("Disable Markdown formatting", comment: "Markdown Accessibility Hint")
        cell.disabledAccessibilityHint = NSLocalizedString("Enable Markdown formatting", comment: "Markdown Accessibility Hint")
        cell.isOn = note.markdown
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
        return cell
    }

    func dequeueCopyPublicURLCell(from tableView: UITableView, at indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
        cell.imageView?.image = .image(name: .copy)
        cell.title = NSLocalizedString("Copy Link", comment: "Copies a Note's Intelrink")
        cell.selectable = false
        return cell
    }

    func dequeueCollaborateCell(from tableView: UITableView, for indexPath: IndexPath) -> Value1TableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: Value1TableViewCell.self, for: indexPath)
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


// MARK: - Action Handlers
//
private extension OptionsViewController {

    @IBAction
    func doneWasPressed() {
        dismiss(animated: true, completion: nil)
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
