import WidgetKit

struct WidgetController {
    @available(iOS 14.0, *)
    static func resetWidgetTimelines() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else {
                return
            }

            if widgets.contains(where: { (widget) -> Bool in
                if widget.configuration as? NoteWidgetIntent != nil {
                    return true
                }

                if widget.configuration as? ListWidgetIntent != nil {
                    return true
                }

                return false
            }) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    static func syncWidgetDefaults(authenticated: Bool) {
        let widgetDefaults = WidgetDefaults.shared
        widgetDefaults.sortMode = Options.shared.listSortMode
        widgetDefaults.loggedIn = authenticated
    }
}
