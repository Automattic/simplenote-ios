import Foundation
import OnePasswordExtension


// MARK: - SPAuthError
//
enum SPAuthError: Error {
    case onePasswordCancelled
    case onePasswordError
    case invalidEmailOrPassword
    case unknown
}


// MARK: - SPAuthHandler
//
class SPAuthHandler {

    ///
    ///
    private let onePasswordService = OnePasswordExtension.shared()

    ///
    ///
    private let simperiumService: SPAuthenticator


    ///
    ///
    init(simperiumService: SPAuthenticator) {
        self.simperiumService = simperiumService
    }


    ///
    ///
    func findOnePasswordLogin(presenter: UIViewController, onCompletion: @escaping (String?, String?, SPAuthError?) -> Void) {
        onePasswordService.findLogin(forURLString: kOnePasswordSimplenoteURL, for: presenter, sender: nil) { (dictionary, error) in
            guard let username = dictionary?[AppExtensionUsernameKey] as? String,
                let password = dictionary?[AppExtensionPasswordKey] as? String
                else {
                    let wrappedError = self.errorFromOnePasswordError(error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    ///
    ///
    func saveLoginToOnePassword(presenter: UIViewController, username: String, password: String, onCompletion: @escaping (String?, String?, SPAuthError?) -> Void) {
        let details = [
            AppExtensionTitleKey: kOnePasswordSimplenoteTitle,
            AppExtensionUsernameKey: username,
            AppExtensionPasswordKey: password
        ]

        let options = [
            AppExtensionGeneratedPasswordMinLengthKey: kOnePasswordGeneratedMinLength,
            AppExtensionGeneratedPasswordMaxLengthKey: kOnePasswordGeneratedMaxLength
        ]

        onePasswordService.storeLogin(forURLString: kOnePasswordSimplenoteURL, loginDetails: details, passwordGenerationOptions: options, for: presenter, sender: nil) { (dictionary, error) in

            guard let username = dictionary?[AppExtensionUsernameKey] as? String,
                let password = dictionary?[AppExtensionPasswordKey] as? String
                else {
                    let wrappedError = self.errorFromOnePasswordError(error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    ///
    ///
    func loginWithWordPressSSO() {
        //  static NSString *SPAuthSessionKey = @"SPAuthSessionKey";
        //
        //    NSString *sessionState = [[NSUUID UUID] UUIDString];
        //    sessionState = [@"app-" stringByAppendingString:sessionState];
        //    [[NSUserDefaults standardUserDefaults] setObject:sessionState forKey:SPAuthSessionKey];
        //    NSString *authUrl = @"https://public-api.wordpress.com/oauth2/authorize?response_type=code&scope=global&client_id=%@&redirect_uri=%@&state=%@";
        //    NSString *requestUrl = [NSString stringWithFormat:authUrl, [SPCredentials WPCCClientID], [SPCredentials WPCCRedirectURL], sessionState];
        //    NSString *encodedUrl = [requestUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        //    SFSafariViewController *sfvc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:encodedUrl]];
        //    sfvc.modalPresentationStyle = UIModalPresentationFormSheet;
        //    [self presentViewController:sfvc animated:YES completion:nil];
        //
        //    [SPTracker trackWPCCButtonPressed];
    }

    ///
    ///
    func loginWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.authenticate(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, responseString) in
            let wrappedError = self.errorFromSimperiumError(responseCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }

    ///
    ///
    func signupWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.create(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, responseString) in
            let wrappedError = self.errorFromSimperiumError(responseCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }

    ///
    ///
    func isOnePasswordAvailable() -> Bool {
        return OnePasswordExtension.shared().isAppExtensionAvailable()
    }
}


// MARK: - Private Methods
//
private extension SPAuthHandler {

    ///
    ///
    func errorFromOnePasswordError(_ error: Error?) -> SPAuthError? {
        guard let error = error as NSError? else {
            return nil
        }

        return error.code == AppExtensionErrorCodeCancelledByUser ? .onePasswordError : .onePasswordCancelled
    }

    ///
    ///
    func errorFromSimperiumError(responseCode: Int) -> SPAuthError? {
        switch responseCode {
        case 401:
            return .invalidEmailOrPassword
        default:
            return .unknown
        }
    }
}
