import Foundation

class PublishNoticePresenter {
    static func presentNotice(for note: Note) {
        switch note.publishState {
        case .publishing:
            NoticeController.shared.present(NoticeFactory.publishing())
            SPTracker.trackPresentedNotice(ofType: .publishing)
        case .published:
            let notice = NoticeFactory.published(note, onCopy: {
                UIPasteboard.general.copyPublicLink(to: note)
                NoticeController.shared.present(NoticeFactory.linkCopied())
                SPTracker.trackPreformedNoticeAction(ofType: .published, noticeType: .copyLink)
            })
            NoticeController.shared.present(notice)
            SPTracker.trackPresentedNotice(ofType: .published)
        case .unpublishing:
            NoticeController.shared.present(NoticeFactory.unpublishing())
            SPTracker.trackPresentedNotice(ofType: .unpublishing)
        case .unpublished:
            let notice = NoticeFactory.unpublished(note, onUndo: {
                SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true)
                SPTracker.trackPreformedNoticeAction(ofType: .unpublished, noticeType: .undo)
            })
            NoticeController.shared.present(notice)
            SPTracker.trackPresentedNotice(ofType: .unpublished)
        }
    }
}
