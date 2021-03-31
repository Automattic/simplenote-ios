import Foundation

class PublishNoticePresenter {
    func presentNotice(for note: Note) {
        switch note.publishState {
        case .publishing:
            NoticeController.shared.present(NoticeFactory.publishing())
        case .published:
            let notice = NoticeFactory.published(note, onCopy: {
                UIPasteboard.general.copyPublicLink(to: note)
                NoticeController.shared.present(NoticeFactory.linkCopied())
            })
            NoticeController.shared.present(notice)
        case .unpublishing:
            NoticeController.shared.present(NoticeFactory.unpublishing())
        case .unpublished:
            let notice = NoticeFactory.unpublished(note, onUndo: {
                SPAppDelegate.shared().publishController.updatePublishState(for: note, to: true)
            })
            NoticeController.shared.present(notice)
        }
    }
}
