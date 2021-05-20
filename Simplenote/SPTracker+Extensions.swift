import Foundation

// MARK: - Verification
//
extension SPTracker {

    static func trackVerificationReviewScreenViewed() {
        trackAutomatticEvent(withName: "verification_review_screen_viewed", properties: nil)
    }

    static func trackVerificationVerifyScreenViewed() {
        trackAutomatticEvent(withName: "verification_verify_screen_viewed", properties: nil)
    }

    static func trackVerificationConfirmButtonTapped() {
        trackAutomatticEvent(withName: "verification_confirm_button_tapped", properties: nil)
    }

    static func trackVerificationChangeEmailButtonTapped() {
        trackAutomatticEvent(withName: "verification_change_email_button_tapped", properties: nil)
    }

    static func trackVerificationResendEmailButtonTapped() {
        trackAutomatticEvent(withName: "verification_resend_email_button_tapped", properties: nil)
    }

    static func trackVerificationDismissed() {
        trackAutomatticEvent(withName: "verification_dismissed", properties: nil)
    }

    static func trackNotice(_ value: String) {
        trackAutomatticEvent(withName: "notice_presented", properties: ["notice": value])
    }

    static func trackNoticeAction(_ value: String, action: String) {
        trackAutomatticEvent(withName: "notice_action_tapped", properties: ["notice": value, "action": action])
    }

    static func trackNoticeLinkCopied() {
        trackNotice("Link Copied")
    }

    static func trackNoticePublishing() {
        trackNotice("Publishing")
    }

    static func trackNoticeUnpublishing() {
        trackNotice("Unpublishing")
    }

    static func trackNoticeNoteTrashed() {
        trackNotice("Note Trashed")
    }

    static func trackNoticeNotesTrashed() {
        trackNotice("Notes Trashed")
    }

    static func trackNoticeUnpublished() {
        trackNotice("Unpublished")
    }

    static func trackNoticePublished() {
        trackNotice("Published")
    }

    static func trackNoticeActionTrashUndo() {
        trackNoticeAction("Note Trashed", action: "Undo")
    }

    static func trackNoticeActionMultipleTrashUndo() {
        trackNoticeAction("Notes Trashed", action: "Undo")
    }

    static func trackNoticeActionUnpublished() {
        trackNoticeAction("Unpublished", action: "Undo")
    }

    static func trackNoticeActionPublished() {
        trackNoticeAction("Published", action: "Copy Link")
    }
}


// MARK: - Shortcuts
//
extension SPTracker {
    private static func trackShortcut(_ value: String) {
        trackAutomatticEvent(withName: "shortcut_used", properties: ["shortcut": value])
    }

    static func trackShortcutSearch() {
        trackShortcut("focus_search")
    }

    static func trackShortcutSearchNext() {
        trackShortcut("search_next")
    }

    static func trackShortcutSearchPrev() {
        trackShortcut("search_previous")
    }

    static func trackShortcutCreateNote() {
        trackShortcut("create_note")
    }

    static func trackShortcutToggleMarkdownPreview() {
        trackShortcut("markdown")
    }

    static func trackShortcutToggleChecklist() {
        trackShortcut("toggle_checklist")
    }
}
