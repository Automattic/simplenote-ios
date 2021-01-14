import Foundation

// MARK: - AccountVerificationController
//
class AccountVerificationController {

    func confirmEmail(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    }

    func resendVerificationEmail(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    }
}
