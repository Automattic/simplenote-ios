import Foundation


// MARK: - UIViewController Shortcuts Helpers
//
extension UIViewController {

    /// Registers the Launch Activity
    ///
    @objc
    func registerLaunchActivity() {
        userActivity = NSUserActivity(type: .launch)
    }

    /// Registers the New Note Activity
    ///
    @objc
    func registerNewNoteActivity() {
        userActivity = NSUserActivity(type: .newNote)
    }
}
