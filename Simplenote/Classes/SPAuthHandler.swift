import Foundation
import OnePasswordExtension


// MARK: - SPAuthHandler
//
class SPAuthHandler {

    /// Simperium Authenticator
    ///
    private let simperiumService: SPAuthenticator

    /// OnePassword Extension convenience property
    ///
    private var onePasswordService: OnePasswordExtension {
        return OnePasswordExtension.shared()
    }

    /// Indicates if OnePassword is available.
    ///
    var isOnePasswordAvailable: Bool {
        return OnePasswordExtension.shared().isAppExtensionAvailable()
    }


    /// Designated Initializer.
    ///
    /// - Parameter simperiumService: Reference to a valid SPAuthenticator instance.
    ///
    init(simperiumService: SPAuthenticator) {
        self.simperiumService = simperiumService
    }


    /// Presents the OnePassword Extension for Login.
    ///
    /// - Note: Errors are mapped into SPAuthError.
    ///
    /// - Parameters:
    ///     - presenter: Source UIViewController from which the extension should be presented.
    ///     - onCompletion: Closure to be executed on completion.
    ///
    func findOnePasswordLogin(presenter: UIViewController, onCompletion: @escaping (String?, String?, SPAuthError?) -> Void) {
        onePasswordService.findLogin(forURLString: kOnePasswordSimplenoteURL, for: presenter, sender: nil) { (dictionary, error) in
            guard let username = dictionary?[AppExtensionUsernameKey] as? String,
                let password = dictionary?[AppExtensionPasswordKey] as? String
                else {
                    let wrappedError = SPAuthError(onePasswordError: error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    /// Presents the OnePassword Extension for Signup purposes: The user will be allowed to store a given set of credentials.
    ///
    /// - Note: Errors are mapped into SPAuthError.
    ///
    /// - Parameters:
    ///     - presenter: Source UIViewController from which the extension should be presented.
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion.
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
                    let wrappedError = SPAuthError(onePasswordError: error)
                    onCompletion(nil, nil, wrappedError)
                    return
            }

            onCompletion(username, password, nil)
        }
    }


    /// Authenticates against the Simperium Backend.
    ///
    /// - Note: Errors are mapped into SPAuthError Instances
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion
    ///
    func loginWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.authenticate(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, _) in
            let wrappedError = SPAuthError(simperiumLoginErrorCode: Int(responseCode))
            onCompletion(wrappedError)
        })
    }


    /// Registers a new user in the Simperium Backend.
    ///
    /// - Note: Errors are mapped into SPAuthError Instances
    ///
    /// - Parameters:
    ///     - username: Simperium Username
    ///     - password: Simperium Password
    ///     - onCompletion: Closure to be executed on completion
    ///
    func signupWithCredentials(username: String, password: String, onCompletion: @escaping (SPAuthError?) -> Void) {
        simperiumService.create(withUsername: username, password: password, success: {
            onCompletion(nil)
        }, failure: { (responseCode, _) in
            let wrappedError = SPAuthError(simperiumSignupErrorCode: Int(responseCode))
            onCompletion(wrappedError)
        })
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

//- (IBAction)signInErrorAction:(NSNotification *)notification
//{
//    NSString *errorMessage = NSLocalizedString(@"An error was encountered while signing in.", @"Sign in error message");
//    if (notification.userInfo != nil && notification.userInfo[@"errorString"]) {
//        errorMessage = [notification.userInfo valueForKey:@"errorString"];
//    }
//
//    [self dismissViewControllerAnimated:YES completion:nil];
//    UIAlertController* errorAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Couldn't Sign In", @"Alert dialog title displayed on sign in error")
//                                                                   message:errorMessage
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//
//    [errorAlert addAction:defaultAction];
//    [self presentViewController:errorAlert animated:YES completion:nil];
//}
}
