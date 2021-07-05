import SwiftUI
import WidgetKit


@available(iOS 14.0, *)
@main
struct SimplenoteWidgets: WidgetBundle {
    var body: some Widget {
        NewNoteWidget()
        NotePreviewWidget()
    }
}
