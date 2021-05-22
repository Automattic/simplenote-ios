import Foundation

class PublishNoticePresenter {
    static func presentNotice(for note: Note) {
        switch note.publishState {
        case .publishing:
            NoticeController.shared.present(NoticeFactory.publishing())
            SPTracker.trackPresentedNotice(kind: .publishing)
        case .published:
            let notice = NoticeFactory.published(note, onCopy: {
                UIPasteboard.general.copyPublicLink(to: note)
                NoticeController.shared.present(NoticeFactory.linkCopied())
                SPTracker.trackPreformedNoticeAction(kind: .published, action: .copyLink)
            })
            NoticeController.shared.present(notice)
            SPTracker.trackPresentedNotice(kind: .published)
        case .unpublishing:
            NoticeController.shared.present(NoticeFactory.unpublishing())
            SPTracker.trackPresentedNotice(kind: .unpublishing)
        case .unpublished:
            let notice = NoticeFactory.unpublished(note, onUndo: {
                SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true)
                SPTracker.trackPreformedNoticeAction(kind: .unpublished, action: .undo)
            })
            NoticeController.shared.present(notice)
            SPTracker.trackPresentedNotice(kind: .unpublished)
        }
    }
}
