import Foundation
import UIKit


// MARK: - AppDelegate Shortcuts Methods
//
extension SPAppDelegate {

    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        guard let type = ActivityType(rawValue: userActivity.activityType) else {
            return false
        }

        switch type {
        case .launch:
            // TODO: Wire Me!
            break
        case .newNote:
            // TODO: Wire Me!
            break
        }

        return true
    }
}
