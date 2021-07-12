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
}

// MARK: - In App Notifications
//
extension SPTracker {

    static func trackPresentedNotice(ofType type: NoticeType) {
        trackAutomatticEvent(withName: "notice_presented", properties: ["notice": type.rawValue])
    }

    static func trackPreformedNoticeAction(ofType type: NoticeType, noticeType: NoticeActionType) {
        trackAutomatticEvent(withName: "notice_action_tapped", properties: ["notice": noticeType.rawValue, "notice_action": type.rawValue])
    }

    enum NoticeType: String {
        case internalLinkCopied = "internal_link_copied"
        case publicLinkCopied = "public_link_copied"
        case publishing
        case unpublishing
        case noteTrashed = "note_trashed"
        case multipleNotesTrashed = "multi_notes_trashed"
        case unpublished
        case published
    }

    enum NoticeActionType: String {
        case undo
        case copyLink = "copy_link"
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

// MARK: Account Deletion
extension SPTracker {
    static func trackDeleteAccountButttonTapped() {
        trackAutomatticEvent(withName: "spios_delete_account_button_clicked", properties: nil)
    }
}
