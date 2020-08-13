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
        return [optionsSection]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableCells()
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

    // MARK: - Table view delegate

    // MARK: - Table Sections
    /// Configures a section to display our main options in
    fileprivate var optionsSection: Section {
        let rows = [
            Row(style: .Switch,
                configuration: { [weak self] (cell: UITableViewCell, row: Row) in
                    guard let cell = cell as? SwitchTableViewCell else {
                        return
                    }
                    cell.textLabel?.text = NSLocalizedString("Pin to Top", comment: "Note Options: Pin to Top")
                    cell.cellSwitch.addTarget(self, action: #selector(self?.handlePinToTop(sender:)), for: .primaryActionTriggered)
                })
        ]
        return Section(headerText: "hi", footerText: "hi", rows: rows)
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

        internal init(headerText: String?, footerText: String?, rows: [Row]) {
            self.headerText = headerText
            self.footerText = footerText
            self.rows = rows
        }
    }

    /// Contains all the data required to render a row
    fileprivate struct Row {
        /// Determines what cell is used to render this row
        let style: Style
        /// Called when this row is tapped. Optional.
        let handler: (() -> Void)?
        /// Called to set up this cell. You should do any view configuration here and assign tagets to elements such as switches.
        let configuration: ((UITableViewCell, Row) -> Void)?

        internal init(style: Style = .Value1, handler: (() -> Void)? = nil, configuration: ((UITableViewCell, Row) -> Void)? = nil) {
            self.style = style
            self.handler = handler
            self.configuration = configuration
        }

        /// Defines a cell identifier that will be used to initialise a cell class
        enum Style: String, CaseIterable {
            case Value1 = "Value1CellIdentifier"
            case Switch = "SwitchCellIdentifier"

            var cellType: UITableViewCell.Type {
                switch self {
                case .Value1:
                    return UITableViewCell.self
                case .Switch:
                    return SwitchTableViewCell.self
                }
            }
        }
    }

    // MARK: - Row Action Handling
    @objc func handlePinToTop(sender: UISwitch) {
        ///Handle pinning logic here
    }
}
