//#pragma mark ================================================================================
//#pragma mark Constants
//#pragma mark ================================================================================
//
//static CGRect SPLoginOnePasswordButtonFrame             = {0.0f, 0.0f, 38.0f, 38.0f};
//static UIEdgeInsets SPLoginOnePasswordImageInsets       = {0.0f, 16.0f, 0.0f, 0.0f};
//static UIEdgeInsets SPLoginOnePasswordImageInsetsSmall  = {0.0f, 16.0f, 3.0f, 0.0f};
//
//static CGFloat SPLoginScreenSmallThreshold              = 480.0f;
//static CGFloat SPLoginFieldMaxWidth                     = 400.0f;
//
//static NSString *SPAuthSessionKey                       = @"SPAuthSessionKey";
//
//
//#pragma mark ================================================================================
//#pragma mark SPLoginViewController
//#pragma mark ================================================================================
//
//@interface SPLoginViewController ()
//@property (nonatomic, strong) UIButton *onePasswordButton;
//@property (nonatomic, strong) UIButton *wpccButton;
//@end
//
//
//@implementation SPLoginViewController

//- (void)viewDidLoad
//{
//    // Force the 'sign in' layout
//    [self setSigningIn:YES];
//    [super viewDidLoad];
//
//    [self setupOnePasswordInterface];
//    [self setupWordPressSignInInterface];
//    [self startObservingChanges];
//    [self startListeningToNotifications];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self reloadOnePassword];
//}

//#pragma mark - Interface Initialization
//
//- (void)setupOnePasswordInterface
//{
//    // Add OnePassword
//    UIButton *onePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [onePasswordButton setImage:[UIImage imageNamed:@"onepassword_button"] forState:UIControlStateNormal];
//    onePasswordButton.frame = SPLoginOnePasswordButtonFrame;
//    onePasswordButton.imageEdgeInsets = self.isSmallScreen ? SPLoginOnePasswordImageInsetsSmall : SPLoginOnePasswordImageInsets;
//    self.onePasswordButton = onePasswordButton;
//
//    // Attach the OnePassword button
//    self.usernameField.rightView = self.onePasswordButton;
//}
//
//- (void)setupWordPressSignInInterface
//{
//    CGFloat fieldWidth = MIN(self.view.frame.size.width, SPLoginFieldMaxWidth);
//    UIColor *lightGreyColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//    UIColor *greyColor = [UIColor colorWithWhite:0.7 alpha:1.0];
//    UIColor *darkGreyColor = [UIColor colorWithWhite:0.4 alpha:1.0];
//
//    // Add the sign in with wordpress.com button
//    CGRect footerFrame = self.tableView.tableFooterView.frame;
//    footerFrame.size.height += 40;
//    self.tableView.tableFooterView.frame = footerFrame;
//
//    UIButton *wpccButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    wpccButton.autoresizingMask = UIViewAutoresizingNone;
//    [wpccButton setUserInteractionEnabled:YES];
//    [wpccButton setTitle:NSLocalizedString(@"Sign in with WordPress.com", "Button title for connecting a WordPress.com account") forState:UIControlStateNormal];
//    [wpccButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 16.0, 0.0, 0.0)];
//    [wpccButton setImage:[UIImage imageNamed:@"icon_wpcom"] forState:UIControlStateNormal];
//    [wpccButton setTitleColor:darkGreyColor forState:UIControlStateNormal];
//    [wpccButton setTitleColor:greyColor forState:UIControlStateHighlighted];
//    [wpccButton addTarget:self action:@selector(wpccSignInAction:) forControlEvents:UIControlEventTouchUpInside];
//    wpccButton.frame = CGRectMake(0, 134.0, fieldWidth-20.0, 40.0);
//    [self.tableView.tableFooterView addSubview:wpccButton];
//
//    UIView *topDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 130.0, fieldWidth, 1.0)];
//    topDivider.autoresizingMask = UIViewAutoresizingNone;
//    [topDivider setBackgroundColor:lightGreyColor];
//    [self.tableView.tableFooterView addSubview:topDivider];
//
//    UIView *bottomDivider = [[UIView alloc] initWithFrame:CGRectMake(0, 177.0, fieldWidth, 1.0)];
//    bottomDivider.autoresizingMask = UIViewAutoresizingNone;
//    [bottomDivider setBackgroundColor:lightGreyColor];
//    [self.tableView.tableFooterView addSubview:bottomDivider];
//
//    self.wpccButton = wpccButton;
//    self.topDivider = topDivider;
//    self.bottomDivider = bottomDivider;
//}
//
//
//#pragma mark - Publisher/Subscriber
//
//- (void)startObservingChanges
//{
//    NSKeyValueObservingOptions options = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial);
//    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(signingIn)) options:options context:nil];
//}
//
//- (void)startListeningToNotifications
//{
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(signInErrorAction:) name:kSignInErrorNotificationName object:nil];
//}
//
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
