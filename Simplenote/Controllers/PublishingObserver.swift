import Foundation
import SimplenoteFoundation

@objc
class PublishingObserver: NSObject {
    let event: PublishEvent
    @objc
    let observedNote: Note
    var observation: NSKeyValueObservation?

    init(event: PublishEvent) {
        self.event = event

        switch event {
        case .published(let note), .unpublished(let note):
            observedNote = note
        }

        super.init()

        setupObservation(event: event)
    }

    func setupObservation(event: PublishEvent) {

        observation = observe(\.observedNote.publishURL,
                              options: [.old, .new]) { object, change in
            if change.oldValue == change.newValue {
                return
            }
            switch event {
            case .published(let note):
                NoticeController.shared.present(self.makePublishNotice(publishing: true, successful: true, option: .undo, note: note))
            case .unpublished(let note):
                NoticeController.shared.present(self.makePublishNotice(publishing: false, successful: true, option: .undo, note: note))
            }

            self.observation?.invalidate()
        }
    }



    enum ActionOption: String {
        case retry = "Retry"
        case undo = "Undo"
    }

    func makePublishNotice(publishing: Bool, successful: Bool, option: ActionOption, note: Note) -> Notice {
        var message = ""

        if successful {
            message = "Note \(publishing ? "published" : "unpublished")."
        } else {
            message = "Could not \(publishing ? "publish" : "unpublish") note."
        }

        let action = NoticeAction(title: option.rawValue) {

            SPObjectManager.shared().updatePublishedState(!publishing, note: note)
        }

        return Notice(message: message, action: action)
    }
}

enum PublishEvent {
    case published(Note)
    case unpublished(Note)
}
