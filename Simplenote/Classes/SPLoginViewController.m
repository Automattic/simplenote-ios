//#pragma mark ================================================================================
//#pragma mark Constants
//#pragma mark ================================================================================
//
//static NSString *SPAuthSessionKey                       = @"SPAuthSessionKey";
//
//
//#pragma mark ================================================================================
//#pragma mark SPLoginViewController
//#pragma mark ================================================================================
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self reloadOnePassword];
//}
//
//#pragma mark - WordPress SignIn
//
//- (IBAction)wpccSignInAction:(id)sender
//{
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
//}
//
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
//
//#pragma mark - Overriden Methods
//
//- (IBAction)performAction:(id)sender
//{
//    [super performAction:sender];
//    
//    // TODO: Implement a proper 'didSignUp' callback
//    if (self.signingIn) {
//        [SPTracker trackUserSignedIn];
//    } else {
//        [SPTracker trackUserAccountCreated];
//    }
//}
//
//
//#pragma mark - KVO Helpers
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    [self reloadOnePassword];
//}
//
//
//#pragma mark - One Password Helpers
//
//- (void)reloadOnePassword
//{
//    // Update the OnePassword Handler
//    SEL hander = self.signingIn ? @selector(findLoginFromOnePassword:) : @selector(saveLoginToOnePassword:);
//    [self.onePasswordButton removeTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//    [self.onePasswordButton addTarget:self action:hander forControlEvents:UIControlEventTouchUpInside];
//
//    // Show the OnePassword view, if it's available
//    BOOL isOnePasswordAvailable         = [[OnePasswordExtension sharedExtension] isAppExtensionAvailable];
//    self.usernameField.rightViewMode    = isOnePasswordAvailable ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
//}
//
//- (IBAction)findLoginFromOnePassword:(id)sender
//{
//    [self.view endEditing:YES];
//    
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
//}
//
//- (IBAction)saveLoginToOnePassword:(id)sender
//{
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
//}
//
//@end
