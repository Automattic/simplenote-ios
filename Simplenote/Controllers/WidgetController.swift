import WidgetKit

class WidgetController: NSObject {
    @available(iOS 14.0, *)
    @objc
    static func resetWidgetTimelines() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else {
                return
            }

            if widgets.contains(where: { (widget) -> Bool in
                if widget.configuration as? NoteWidgetIntent != nil {
                    return true
                }

                // Add check for ListWidgetIntent when created later

                return false
            }) {
                NSLog("Reloading all widgets")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    @objc
    static func syncWidgetDefaults(isLoggedIn loggedIn: Bool) {
        guard let widgetDefaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain) else {
            return
        }

        // Set listsortmode default
        widgetDefaults.set(UserDefaults.standard.integer(forKey: .listSortMode), forKey: .listSortMode)

        // User is logged in
        widgetDefaults.set(loggedIn, forKey: .accountIsLoggedIn)
    }
}
