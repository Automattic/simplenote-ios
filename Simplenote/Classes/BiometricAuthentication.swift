import Foundation
import LocalAuthentication

// MARK: - BiometricAuthentication
//
class BiometricAuthentication {
    /// Biometry
    ///
    enum Biometry {
        case touchID
        case faceID
    }

    /// Available biometry type or nil if biometry is not supported or user disabled it in settings
    ///
    var availableBiometry: Biometry? {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return nil
        }

        switch context.biometryType {
        case .none:
            return nil
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return nil
        }
    }

    /// Evaluate biometry
    ///
    func evaluate(completion: @escaping (_ success: Bool) -> Void) {
        guard availableBiometry != nil else {
            completion(false)
            return
        }

        let context = LAContext()
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: Localization.biometryReason) { (success, _) in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}

// MARK: - Localization
//
private struct Localization {
    static let biometryReason = NSLocalizedString("To unlock the application", comment: "Touch ID reason/explanation")
}
