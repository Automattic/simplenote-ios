import Foundation

class PublishNoticePresenter {
    static func presentNotice(for note: Note) {
        switch note.publishState {
        case .publishing:
            NoticeController.shared.present(NoticeFactory.publishing())
            SPTracker.trackNoticePublishing()
        case .published:
            let notice = NoticeFactory.published(note, onCopy: {
                UIPasteboard.general.copyPublicLink(to: note)
                NoticeController.shared.present(NoticeFactory.linkCopied())
                SPTracker.trackNoticeActionPublished()
            })
            NoticeController.shared.present(notice)
            SPTracker.trackNoticePublished()
        case .unpublishing:
            NoticeController.shared.present(NoticeFactory.unpublishing())
            SPTracker.trackNoticeUnpublishing()
        case .unpublished:
            let notice = NoticeFactory.unpublished(note, onUndo: {
                SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true)
                SPTracker.trackNoticeActionUnpublished()
            })
            NoticeController.shared.present(notice)
            SPTracker.trackNoticeUnpublished()
        }
    }
}
