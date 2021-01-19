import Foundation

// MARK: - Verification
//
extension SPTracker {
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
