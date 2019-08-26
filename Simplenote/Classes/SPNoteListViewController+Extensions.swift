import Foundation
import UIKit


// MARK: - Internal Methods
//
extension SPNoteListViewController {

    @objc
    func registerForPeekAndPop() {
        registerForPreviewing(with: self, sourceView: tableView)
    }
}


// MARK: - UIViewControllerPreviewingDelegate Conformance
//
extension SPNoteListViewController: UIViewControllerPreviewingDelegate {

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }

        previewingContext.sourceRect = tableView.rectForRow(at: indexPath)

        let note = fetchedResultsController.object(at: indexPath)
        let editorViewController = SPAppDelegate.shared().noteEditorViewController
        editorViewController.update(note)
        editorViewController.isPreviewing = true

        return editorViewController
    }

    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let editorViewController = viewControllerToCommit as? SPNoteEditorViewController else {
            return
        }

        editorViewController.isPreviewing = false
        navigationController?.pushViewController(editorViewController, animated: true)
    }
}


// MARK: - UITableViewDelegate Conformance
//
extension SPNoteListViewController: UITableViewDelegate {

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let reuseIdentifier = SPTableViewHeaderFooterView.reuseIdentifier
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? SPTableViewHeaderFooterView else {
            assertionFailure()
            return nil
        }

        let section = self.section(atIndex: section)
        headerView.title = section.title?.uppercased()
        headerView.titleColor = section.titleColor
        headerView.titleIsHiden = section.titleIsHidden
        headerView.bottomBorderColor = section.bottomBorderColor
        headerView.bottomBorderIsThick = section.bottomBorderIsExtraThick

        return headerView
    }


    private func section(atIndex index: Int) -> Section {
        guard let sections = fetchedResultsController.sections, sections.count > 1 else {
            return .everything
        }

        return Section(rawValue: index) ?? .everything
    }
}


// MARK: - List Sections
//
private enum Section: Int {
    case pinned     = 0
    case unpinned   = 1
    case everything = 1000
}

extension Section {

    var title: String? {
        switch self {
        case .pinned:
            return NSLocalizedString("Pinned", comment: "Pinned List Section Title")
        default:
            return nil
        }
    }

    var titleColor: UIColor? {
        return .color(name: .simplenoteSlateGrey)
    }

    var titleIsHidden: Bool {
        return self != .pinned
    }

    var bottomBorderColor: UIColor? {
        switch self {
        case .unpinned:
            return .color(name: .simplenoteLightPeriwinkle)
        default:
            return .color(name: .simplenoteCloudyBlue)
        }
    }

    var bottomBorderIsExtraThick: Bool {
        return self == .unpinned
    }
}
