import WidgetKit

struct WidgetController {
    @available(iOS 14.0, *)
    static func resetWidgetTimelines() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else {
                return
            }

            if widgets.contains(where: { widget in
                widget.configuration as? NoteWidgetIntent != nil
            }) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    static func syncWidgetDefaults(authenticated: Bool) {
        guard let widgetDefaults = UserDefaults(suiteName: SimplenoteConstants.sharedGroupDomain) else {
            return
        }
        widgetDefaults.set(UserDefaults.standard.integer(forKey: .listSortMode), forKey: .listSortMode)

        widgetDefaults.set(authenticated, forKey: .accountIsLoggedIn)
    }
}
