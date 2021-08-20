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
        let widgetDefaults = WidgetDefaults.shared
        widgetDefaults.sortMode = Options.shared.listSortMode
        widgetDefaults.loggedIn = authenticated
    }
}
