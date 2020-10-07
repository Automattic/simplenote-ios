import Foundation
import UIKit


// MARK: - OptionsViewController
//
class OptionsViewController: UIViewController {

    /// Options TableView
    ///
    @IBOutlet private var tableView: UITableView!

    /// Note for which we'll render the current Options
    ///
    private let note: Note

    /// Sections onScreen
    ///
    private var sections = [Section]()

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
        refreshSections()
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
}


// MARK: - Interface
//
private extension OptionsViewController {

    func refreshStyle() {
        view.backgroundColor = .simplenoteTableViewBackgroundColor
        tableView.applySimplenoteGroupedStyle()
    }
}


// MARK: - Action Handlers
//
private extension OptionsViewController {

    @IBAction
    func doneWasPressed() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction
    func trashWasPressed() {
        NSLog("Trash!")
    }

    @IBAction
    func pinnedWasPressed(_ sender: UISwitch) {
        NSLog("Pin! \(sender.isOn)")
    }

    @IBAction
    func markdownWasPressed(_ sender: UISwitch) {
        NSLog("Markdown! \(sender.isOn)")
    }

    @IBAction
    func shareWasPressed() {
        NSLog("Share!")
    }

    @IBAction
    func historyWasPressed() {
        NSLog("History!")
    }

    @IBAction
    func publishWasPressed(_ sender: UISwitch) {
        NSLog("Publish! \(sender.isOn)")
    }

    @IBAction
    func copyLinkWasPressed() {
        NSLog("Copy!")
    }

    @IBAction
    func collaborateWasPressed() {
        NSLog("Collab!")
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
        perform(rowAtIndexPath(indexPath).handler)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)

        configureCell(cell, with: row)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
}


// MARK: - Helper API(s)
//
private extension OptionsViewController {

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        sections[indexPath.section].rows[indexPath.row]
    }

    func configureCell(_ cell: UITableViewCell, with row: Row) {
        switch cell {
        case let cell as SwitchTableViewCell:
            configureSwitchCell(cell, for: row)
        case let cell as Value1TableViewCell:
            configureValue1Cell(cell, for: row)
        default:
            fatalError()
        }
    }

    func configureSwitchCell(_ switchCell: SwitchTableViewCell, for row: Row) {
        guard case let .switch(selected) = row.kind else {
            fatalError()
        }
        
        switchCell.onChange = { [weak self] switchControl in
            self?.perform(row.handler, with: switchControl)
        }

        switchCell.switchControl.isOn = selected
        switchCell.textLabel?.text = row.title
    }

    func configureValue1Cell(_ valueCell: Value1TableViewCell, for row: Row) {
        valueCell.textLabel?.text = row.title
        valueCell.textLabel?.textColor = row.destructive ? .simplenoteDestructiveActionColor : .simplenoteTextColor
    }
}


// MARK: - Intermediate Representations
//
private extension OptionsViewController {

    func refreshSections() {
        sections = self.sections(for: note)
        tableView.reloadData()
    }

    func sections(for note: Note) -> [Section] {
        return [
            Section(rows: [
                        Row(kind: .switch(selected: note.pinned),
                            title: NSLocalizedString("Pin to Top", comment: "Toggles the Pinned State"),
                            handler: #selector(pinnedWasPressed)),

                        Row(kind: .switch(selected: note.markdown),
                            title: NSLocalizedString("Markdown", comment: "Toggles the Markdown State"),
                            handler: #selector(markdownWasPressed)),

                        Row(kind: .value1,
                            title: NSLocalizedString("Share", comment: "Opens the Share Sheet"),
                            handler: #selector(shareWasPressed)),

                        Row(kind: .value1,
                            title: NSLocalizedString("History", comment: "Opens the Note's History"),
                            handler: #selector(historyWasPressed))
                    ]),
            Section(header: NSLocalizedString("Public Link",
                                              comment: "Publish to Web Section Header"),
                    footer: NSLocalizedString("Publish your note to the web and generate a sharable URL.",
                                              comment: "Publish to Web Section Footer"),
                    rows: [
                        Row(kind: .switch(selected: note.published),
                            title: NSLocalizedString("Publish", comment: "Publishes a Note to the Web"),
                            handler: #selector(publishWasPressed)),

                        Row(kind: .value1,
                            title: NSLocalizedString("Copy Link", comment: "Copies a Note's Intelrink"),
                            handler: #selector(copyLinkWasPressed))
                    ]),
            Section(rows: [
                        Row(kind: .value1,
                            title: NSLocalizedString("Collaborate", comment: "Opens the Collaborate UI"),
                            handler: #selector(collaborateWasPressed))

                    ]),
            Section(rows: [
                        Row(kind: .value1,
                            title: NSLocalizedString("Move to Trash", comment: "Delete Action"),
                            destructive: true,
                            handler: #selector(trashWasPressed))
                    ]),
        ]
    }
}


// MARK: - Section: Defines a TableView Section
//
private struct Section {
    let header: String?
    let footer: String?
    let rows: [Row]

    init(header: String? = nil, footer: String? = nil, rows: [Row]) {
        self.header = header
        self.footer = footer
        self.rows = rows
    }
}


// MARK: - Supported TableView Rows
//
private struct Row {
    let kind: RowKind
    let title: String
    let destructive: Bool
    let handler: Selector

    init(kind: RowKind, title: String, destructive: Bool = false, handler: Selector) {
        self.kind = kind
        self.title = title
        self.destructive = destructive
        self.handler = handler
    }
}

private enum RowKind {
    case value1
    case `switch`(selected: Bool)
}

// MARK: - Row API(s)
//
private extension Row {

    var reuseIdentifier: String {
        switch kind {
        case .value1:
            return Value1TableViewCell.reuseIdentifier
        case .switch:
            return SwitchTableViewCell.reuseIdentifier
        }
    }
}
