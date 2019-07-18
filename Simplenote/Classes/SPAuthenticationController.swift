import Foundation
import OnePasswordExtension


//
//
class SPAuthenticationController {

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
    func findOnePasswordLogin(presenter: UIViewController, onCompletion: @escaping (String, String) -> Void) {
        onePasswordService.findLogin(forURLString: kOnePasswordSimplenoteURL, for: presenter, sender: nil) { (payload, error) in
            guard let dictionary = payload,
                let username = dictionary[AppExtensionUsernameKey] as? String,
                let password = dictionary[AppExtensionPasswordKey] as? String else {
                    return
            }

            onCompletion(username,password)
        }

        //    [[OnePasswordExtension sharedExtension] findLoginForURLString:kOnePasswordSimplenoteURL
        //                                                forViewController:self
        //                                                           sender:sender
        //                                                       completion:^(NSDictionary *loginDict, NSError *error) {
        //                                                           if (!loginDict) {
        //                                                               if (error.code != AppExtensionErrorCodeCancelledByUser) {
        //                                                                   NSLog(@"OnePassword Error: %@", error);
        //                                                                   [SPTracker trackOnePasswordLoginFailure];
        //                                                               }
        //                                                               return;
        //                                                           }
        //
        //                                                           self.usernameField.text = loginDict[AppExtensionUsernameKey];
        //                                                           self.passwordField.text = loginDict[AppExtensionPasswordKey];
        //
        //                                                           [SPTracker trackOnePasswordLoginSuccess];
        //                                                           [super performAction:nil];
        //                                                       }];
    }


    ///
    ///
    func saveLoginToOnePassword(username: String, password: String) {
        //    NSDictionary *newLoginDetails = @{
        //        AppExtensionTitleKey        : kOnePasswordSimplenoteTitle,
        //        AppExtensionUsernameKey     : self.usernameField.text ?: [NSString string],
        //        AppExtensionPasswordKey     : self.passwordField.text ?: [NSString string],
        //    };
        //
        //    NSDictionary *passwordGenerationOptions = @{
        //        AppExtensionGeneratedPasswordMinLengthKey: @(kOnePasswordGeneratedMinLength),
        //        AppExtensionGeneratedPasswordMaxLengthKey: @(kOnePasswordGeneratedMaxLength)
        //    };
        //
        //    [[OnePasswordExtension sharedExtension] storeLoginForURLString:kOnePasswordSimplenoteURL
        //                                                      loginDetails:newLoginDetails
        //                                         passwordGenerationOptions:passwordGenerationOptions
        //                                                 forViewController:self
        //                                                            sender:sender
        //                                                        completion:^(NSDictionary *loginDict, NSError *error) {
        //
        //                                                            if (!loginDict) {
        //                                                                if (error.code != AppExtensionErrorCodeCancelledByUser) {
        //                                                                    NSLog(@"OnePassword Error: %@", error);
        //                                                                    [SPTracker trackOnePasswordSignupFailure];
        //                                                                }
        //                                                                return;
        //                                                            }
        //
        //                                                            self.usernameField.text = loginDict[AppExtensionUsernameKey] ?: [NSString string];
        //                                                            self.passwordField.text = loginDict[AppExtensionPasswordKey] ?: [NSString string];
        //                                                            self.passwordConfirmField.text = self.passwordField.text;
        //
        //                                                            [SPTracker trackOnePasswordSignupSuccess];
        //                                                        }];
    }


    ///
    ///
    func signIntoWordPress() {
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
}
