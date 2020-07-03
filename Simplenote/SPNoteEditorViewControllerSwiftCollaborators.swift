import UIKit

// MARK: - SPNoteEditorViewControllerSwiftCollaborators: Wrapper to store swift objects in note editor obj-c view controller
//
@objc
class SPNoteEditorViewControllerSwiftCollaborators: NSObject {
    weak var historyLoader: SPHistoryLoader?
    weak var historyCardViewController: UIViewController?
}
