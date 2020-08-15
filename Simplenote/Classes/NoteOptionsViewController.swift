//
//  NoteOptionsViewController.swift
//  Simplenote
//
//  Created by Matthew Cheetham on 11/08/2020.
//  Copyright © 2020 Automattic. All rights reserved.
//

import UIKit

/// A class used to display options for the note that is currently being edited
class NoteOptionsViewController: UITableViewController {

    /// Array of `Section`s to display in the view.
    /// Each `Section` has `Rows` that are used for display
    fileprivate var sections: [Section] {
        return [optionsSection, linkSection, collaborationSection, trashSection]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Options", comment: "Note Options: Title")
        setupDoneButton()
        setupViewStyles()
        registerTableCells()
    }

    // MARK: - View Setup
    /// Configures a dismiss button for the navigation bar
    func setupDoneButton() {
        let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Note options: Done"),
                                         style: .done,
                                         target: self,
                                         action: #selector(handleDone(button:)))
        doneButton.accessibilityHint = NSLocalizedString("Dismisses the note options view", comment: "Accessibility hint for dismissing the note options view")
        navigationItem.rightBarButtonItem = doneButton
    }

    /// Applies Simplenote styling to the view controller
    func setupViewStyles() {
        tableView.backgroundColor = .simplenoteTableViewBackgroundColor
        tableView.separatorColor = .simplenoteDividerColor
    }

    // MARK: - Table helpers
    /// Registers cell types that can be displayed by the note options view
    func registerTableCells() {
        for rowStyle in Row.Style.allCases {
            tableView.register(rowStyle.cellType, forCellReuseIdentifier: rowStyle.rawValue)
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = sections[indexPath.section].rows[indexPath.row]
        let cell = cellFor(row: row, at: indexPath)
        row.configuration?(cell, row)
        return cell
    }

    fileprivate func cellFor(row: Row, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: row.style.rawValue, for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].headerText
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerText
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.handler?()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Table Sections
    /// Configures a section to display our main options in
    fileprivate var optionsSection: Section {
        let rows = [
            Row(style: .Switch,
                configuration: { [weak self] (cell: UITableViewCell, row: Row) in
                    let cell = cell as! SwitchTableViewCell
                    cell.textLabel?.text = NSLocalizedString("Pin to Top", comment: "Note Options: Pin to Top")
                    cell.cellSwitch.addTarget(self, action: #selector(self?.handlePinToTop(sender:)), for: .primaryActionTriggered)
                    cell.cellSwitch.accessibilityHint = NSLocalizedString("Tap to toggle pin to top", comment: "Accessibility hint for toggling pin to top")
                }
            ),
            Row(style: .Switch,
                configuration: { [weak self] (cell: UITableViewCell, row: Row) in
                    let cell = cell as! SwitchTableViewCell
                    cell.textLabel?.text = NSLocalizedString("Markdown", comment: "Note Options: Toggle Markdown")
                    cell.cellSwitch.addTarget(self, action: #selector(self?.handleMarkdown(sender:)), for: .primaryActionTriggered)
                    cell.cellSwitch.accessibilityHint = NSLocalizedString("Tap to toggle markdown mode", comment: "Accessibility hint for toggling markdown mode")
                }
            ),
            Row(style: .Value1,
                configuration: { (cell: UITableViewCell, row: Row) in
                    let cell = cell as! Value1TableViewCell
                    cell.textLabel?.text = NSLocalizedString("Share", comment: "Note Options: Show Share Options")
                    cell.accessibilityHint = NSLocalizedString("Tap to open share options", comment: "Accessibility hint on cell that activates share sheet")
                },
                handler: { [weak self] in
                    self?.handleShare()
                }
            ),
            Row(style: .Value1,
                configuration: { (cell: UITableViewCell, row: Row) in
                    let cell = cell as! Value1TableViewCell
                    cell.textLabel?.text = NSLocalizedString("History", comment: "Note Options: Show History")
                    cell.accessibilityHint = NSLocalizedString("Tap to open history", comment: "Accessibility hint on cell that opens note history view")
                },
                handler: { [weak self] in
                    self?.handleHistory()
                }
            )
        ]
        return Section(rows: rows)
    }

    /// Configures a section to display our link options in
    fileprivate var linkSection: Section {
        let rows = [
            Row(style: .Switch,
                configuration: { [weak self] (cell: UITableViewCell, row: Row) in
                    let cell = cell as! SwitchTableViewCell
                    cell.textLabel?.text = NSLocalizedString("Publish", comment: "Note Options: Publish")
                    cell.cellSwitch.addTarget(self, action: #selector(self?.handlePublish(sender:)), for: .primaryActionTriggered)
                    cell.cellSwitch.accessibilityHint = NSLocalizedString("Tap to toggle publish state", comment: "Accessibility hint on switch that toggles publish state")
                }
            ),
            Row(style: .Value1,
                configuration: { (cell: UITableViewCell, row: Row) in
                    let cell = cell as! Value1TableViewCell
                    cell.textLabel?.text = NSLocalizedString("Copy Link", comment: "Note Options: Copy Link")
                    cell.textLabel?.textColor = .simplenoteGray20Color
                    cell.accessibilityHint = NSLocalizedString("Tap to copy link", comment: "Accessibility hint on cell that copies public URL of note")
                },
                handler: { [weak self] in
                    self?.handleCopyLink()
                }
            )
        ]
        return Section(headerText: NSLocalizedString("Public Link", comment: "Note Options Header: Public Link"),
                       footerText: NSLocalizedString("Publish your note to the web and generate a shareable URL", comment: "Note Options Footer: Publish your note to generate a URL"),
                       rows: rows)
    }

    /// Configures a section to display our collaboration details
    fileprivate var collaborationSection: Section {
        let rows = [
            Row(style: .Value1,
                configuration: { (cell: UITableViewCell, row: Row) in
                    let cell = cell as! Value1TableViewCell
                    cell.textLabel?.text = NSLocalizedString("Collaborate", comment: "Note Options: Collaborate")
                    cell.accessibilityLabel = NSLocalizedString("Tap to open collaboration menu", comment: "Accessibility hint on cell that opens collaboration menu")
                },
                handler: { [weak self] in
                    self?.handleCollaborate()
                }
            )
        ]
        return Section(rows: rows)
    }

    /// Configures a section to display our trash options
    fileprivate var trashSection: Section {
        let rows = [
            Row(style: .Value1,
                configuration: { (cell: UITableViewCell, row: Row) in
                    let cell = cell as! Value1TableViewCell
                    cell.textLabel?.text = NSLocalizedString("Move to Trash", comment: "Note Options: Move to Trash")
                    cell.textLabel?.textColor = .simplenoteDestructiveActionColor
                    cell.accessibilityHint = NSLocalizedString("Tap to move this note to trash", comment: "Accessibility hint on cell that moves a note to trash")
                },
                handler: { [weak self] in
                    self?.handleMoveToTrash()
                }
            )
        ]
        return Section(rows: rows)
    }

    // MARK: - Private Nested Classes
    /// Contains all data required to render a `UITableView` section
    fileprivate struct Section {
        /// Optional text to display as standard header text above the `UITableView` section
        let headerText: String?

        /// Optional text to display as standard footer text below the `UITableView` section
        let footerText: String?

        /// Any rows to be displayed inside this `UITableView` section
        let rows: [Row]

        internal init(headerText: String? = nil, footerText: String? = nil, rows: [Row]) {
            self.headerText = headerText
            self.footerText = footerText
            self.rows = rows
        }
    }

    /// Contains all the data required to render a row
    fileprivate struct Row {
        /// Determines what cell is used to render this row
        let style: Style

        /// Called to set up this cell. You should do any view configuration here and assign targets to elements such as switches.
        let configuration: ((UITableViewCell, Row) -> Void)?

        /// Called when this row is tapped. Optional.
        let handler: (() -> Void)?

        internal init(style: Style = .Value1, configuration: ((UITableViewCell, Row) -> Void)? = nil, handler: (() -> Void)? = nil) {
            self.style = style
            self.configuration = configuration
            self.handler = handler
        }

        /// Defines a cell identifier that will be used to initialise a cell class
        enum Style: String, CaseIterable {
            case Value1 = "Value1CellIdentifier"
            case Switch = "SwitchCellIdentifier"

            var cellType: UITableViewCell.Type {
                switch self {
                case .Value1:
                    return Value1TableViewCell.self
                case .Switch:
                    return SwitchTableViewCell.self
                }
            }
        }
    }

    // MARK: - Row Action Handling
    @objc
    func handlePinToTop(sender: UISwitch) {
        ///Handle pinning logic here
    }

    @objc
    func handleMarkdown(sender: UISwitch) {
        ///Handle markdown logic here
    }

    func handleShare() {
        ///Handle share logic here
    }

    func handleHistory() {
        ///Handle history logic here
    }

    @objc
    func handlePublish(sender: UISwitch) {
        ///Handle publish logic here
    }

    func handleCopyLink() {
        ///Handle copy link logic here
    }

    func handleCollaborate() {
        ///Handle collaboration logic here
    }

    func handleMoveToTrash() {
        ///Handle move to tash logic here
    }

    // MARK: - Navigation button handling
    @objc
    func handleDone(button: UIBarButtonItem) {
        dismiss(animated: true)
    }
}
