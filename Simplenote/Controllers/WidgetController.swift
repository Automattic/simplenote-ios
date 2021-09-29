import WidgetKit
import Intents


struct WidgetController {
    @available(iOS 14.0, *)
    static func resetWidgetTimelines() {
        WidgetCenter.shared.getCurrentConfigurations { result in
            guard case .success(let widgets) = result else {
                return
            }

            if widgets.contains(where: { widget in
                /// Note:
                /// We *used to* check if `widget.configuration` was of the `NoteWidgetIntent` / `ListWidgetIntent`.
                /// This caused (a million) Swift compiler errors in Xcode 13.
                /// In order to remediate this, we're disabling `codegen` in the `intentdefinition` file, and simply checking if there's
                /// an Intent set up there.
                /// The only scenario in which we wouldn't wanna reload the Timelines is the `New Note` widget (which does not display any dynamic content).
                ///
                return widget.configuration != nil
            }) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    static func syncWidgetDefaults(authenticated: Bool, sortMode: SortMode) {
        let widgetDefaults = WidgetDefaults.shared
        widgetDefaults.sortMode = sortMode
        widgetDefaults.loggedIn = authenticated
    }
}
