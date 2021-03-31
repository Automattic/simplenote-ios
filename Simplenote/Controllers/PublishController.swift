import Foundation

class PublishController {
    private let publishStateObserver: PublishStateObserver

    init(publishStateObserver: PublishStateObserver) {
        self.publishStateObserver = publishStateObserver
    }

    func updatePublishState(for note: Note, to published: Bool) {
        if note.published == published {
            return
        }

        changePublishState(for: note, to: published)

        publishStateObserver.beginListeningForChanges(to: note, timeOut: Constants.timeOut) { (listener, note) in
            switch note.publishState {
            case .published:
                let notice = NoticeFactory.published(note, onCopy: {
                    UIPasteboard.general.copyPublicLink(to: note)
                    NoticeController.shared.present(NoticeFactory.linkCopied())
                })
                NoticeController.shared.present(notice)
            case .unpublished:
                let notice = NoticeFactory.unpublished(note, onUndo: {
                    SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true)
                })
                NoticeController.shared.present(notice)
            }

            listener.endListeningForChanges(to: note)
        }

        presentPendingPublishNotice(published)
    }

    private func changePublishState(for note: Note, to published: Bool) {
        note.published = published
        note.modificationDate = Date()
        SPAppDelegate.shared().save()
    }

    private func presentPendingPublishNotice(_ published: Bool) {
        let notice: Notice = published ? NoticeFactory.publishing() : NoticeFactory.unpublishing()
        NoticeController.shared.present(notice)
    }
}

private struct Constants {
    static let timeOut = TimeInterval(5)
}
