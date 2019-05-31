//
//  SPSortOrderViewController.swift
//  Simplenote
//
//  Created by Lantean on 5/31/19.
//  Copyright © 2019 Automattic. All rights reserved.
//

import Foundation
import UIKit


// MARK: -
//
class SPSortOrderViewController: UITableViewController {

    init() {
        super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        refreshStyle()
    }
}


// MARK: -
//
extension SPSortOrderViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Settings.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueCell(from: tableView)
        let row = Row.allCases[indexPath.row]

        setupCell(cell, with: row)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


// MARK: -
//
private extension SPSortOrderViewController {

    func setupNavigationItem() {
        title = NSLocalizedString("Sort Order", comment: "Sort Order for the Notes List")
    }

    func setupCell(_ cell: UITableViewCell, with row: Row) {
        cell.textLabel?.text = row.description
    }

    func applyStyle(to cell: UITableViewCell) {
        guard let theme = VSThemeManager.shared()?.theme() else {
            fatalError()
        }

        let backgroundView = UIView()
        backgroundView.backgroundColor = theme.color(forKey: .noteCellBackgroundSelectionColor)

        cell.backgroundColor = theme.color(forKey: .backgroundColor)
        cell.selectedBackgroundView = backgroundView
        cell.detailTextLabel?.textColor = theme.color(forKey: .tableViewDetailTextLabelColor)
        cell.textLabel?.textColor = theme.color(forKey: .tableViewTextLabelColor)
    }

    func refreshStyle() {
        tableView.applyDefaultGroupedStyling()
    }

    func dequeueCell(from tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Settings.reusableIdentifier) {
            return cell
        }

        let cell = UITableViewCell(style: .default, reuseIdentifier: Settings.reusableIdentifier)
        applyStyle(to: cell)
        return cell
    }
}


//
//
enum Settings {
    static let numberOfSections = 1
    static let reusableIdentifier = "reusableIdentifier"
}


//
//
private enum Row: CaseIterable {
    case modifiedNewest
    case modifiedOldest
    case createdNewest
    case createdOldest
    case alphabeticallyAscending
    case alphabeticallyDescending

    var description: String {
        switch self {
        case .modifiedNewest:
            return NSLocalizedString("Newest modified date", comment: "")
        case .modifiedOldest:
            return NSLocalizedString("Oldest modified date", comment: "")
        case .createdNewest:
            return NSLocalizedString("Newest created date", comment: "")
        case .createdOldest:
            return NSLocalizedString("Oldest created date", comment: "")
        case .alphabeticallyAscending:
            return NSLocalizedString("Alphabetically, A-Z", comment: "")
        case .alphabeticallyDescending:
            return NSLocalizedString("Alphabetically, Z-A", comment: "")
        }
    }
}
