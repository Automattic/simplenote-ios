#import "SPSettingsViewController.h"
#import "SPAppDelegate.h"
#import "SPConstants.h"
#import "StatusChecker.h"
#import "SPTracker.h"
#import "SPDebugViewController.h"
#import "Simplenote-Swift.h"
#import "Simperium+Simplenote.h"

NSString *const SPAlphabeticalTagSortPref                           = @"SPAlphabeticalTagSortPref";
NSString *const SPThemePref                                         = @"SPThemePref";
NSString *const SPSustainerAppIconName                              = @"AppIcon-Sustainer";
CGFloat  const SPSettingsTableViewSpacing                           = 25.0;

@interface SPSettingsViewController ()
@property (nonatomic, strong) UISwitch      *condensedNoteListSwitch;
@property (nonatomic, strong) UISwitch      *alphabeticalTagSortSwitch;
@property (nonatomic, strong) UISwitch      *biometrySwitch;
@property (nonatomic, strong) UISwitch      *sustainerIconSwitch;
@property (nonatomic, strong) UITextField   *pinTimeoutTextField;
@property (nonatomic, strong) UIPickerView  *pinTimeoutPickerView;
@property (nonatomic, strong) UIToolbar     *doneToolbar;
@end

@implementation SPSettingsViewController {
    NSArray *timeoutPickerOptions;
}

#define kTagNoteListSort        1
#define kTagTagsListSort        2
#define kTagCondensedNoteList   3
#define kTagTheme               4
#define kTagPasscode            5
#define kTagTimeout             6
#define kTagTouchID             7
#define kTagSustainerIcon       8

typedef NS_ENUM(NSInteger, SPOptionsViewSections) {
    SPOptionsViewSectionsNotes          = 0,
    SPOptionsViewSectionsTags           = 1,
    SPOptionsViewSectionsAppearance     = 2,
    SPOptionsViewSectionsSustainer      = 3,
    SPOptionsViewSectionsSecurity       = 4,
    SPOptionsViewSectionsAccount        = 5,
    SPOptionsViewSectionsDelete         = 6,
    SPOptionsViewSectionsAbout          = 7,
    SPOptionsViewSectionsHelp           = 8,
    SPOptionsViewSectionsDebug          = 9,
    SPOptionsViewSectionsCount          = 10,
};

typedef NS_ENUM(NSInteger, SPOptionsAccountRow) {
    SPOptionsAccountRowDescription      = 0,
    SPOptionsAccountRowPrivacy          = 1,
    SPOptionsAccountRowLogout           = 2,
    SPOptionsAccountRowCount            = 3
};

typedef NS_ENUM(NSInteger, SPOptionsNotesRow) {
    SPOptionsPreferencesRowSort         = 0,
    SPOptionsPreferencesRowCondensed    = 1,
    SPOptionsNotesRowCount              = 2
};

typedef NS_ENUM(NSInteger, SPOptionsTagsRow) {
    SPOptionsPreferencesRowTagSort      = 0,
    SPOptionsTagsRowCount               = 1
};

typedef NS_ENUM(NSInteger, SPOptionsAppearanceRow) {
    SPOptionsPreferencesRowTheme        = 0,
    SPOptionsAppearanceRowCount         = 1
};

typedef NS_ENUM(NSInteger, SPOptionsSustainerRow) {
    SPOptionsAccountSustainerIcon       = 0,
    SPOptionsAccountSustainerCount      = 1
};


typedef NS_ENUM(NSInteger, SPOptionsSecurityRow) {
    SPOptionsSecurityRowRowPasscode     = 0,
    SPOptionsSecurityRowRowBiometry     = 1,
    SPOptionsSecurityRowTimeout         = 2,
    SPOptionsSecurityRowRowCount        = 3
};

typedef NS_ENUM(NSInteger, SPOptionsDeleteRow) {
    SPOptionsDeleteRowTitle              = 0,
    SPOptionsDeleteRowCount              = 1
};

typedef NS_ENUM(NSInteger, SPOptionsAboutRow) {
    SPOptionsAboutRowTitle              = 0,
    SPOptionsAboutRowCount              = 1
};

typedef NS_ENUM(NSInteger, SPOptionsHelpRow) {
    SPOptionsHelpRowTitle              = 0,
    SPOptionsHelpRowCount              = 1
};

typedef NS_ENUM(NSInteger, SPOptionsDebugRow) {
    SPOptionsDebugRowStats              = 0,
    SPOptionsDebugRowCount              = 1
};

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if (self = [super initWithStyle:UITableViewStyleGrouped])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    timeoutPickerOptions = @[NSLocalizedString(@"Off", @"Instant passcode lock timeout"),
                       NSLocalizedString(@"15 Seconds", @"15 seconds passcode lock timeout"),
                       NSLocalizedString(@"30 Seconds", @"30 seconds passcode lock timeout"),
                       NSLocalizedString(@"1 Minute", @"1 minute passcode lock timeout"),
                       NSLocalizedString(@"2 Minutes", @"2 minutes passcode lock timeout"),
                       NSLocalizedString(@"3 Minutes", @"3 minutes passcode lock timeout"),
                       NSLocalizedString(@"4 Minutes", @"4 minutes passcode lock timeout"),
                       NSLocalizedString(@"5 Minutes", @"5 minutes passcode lock timeout")];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationItem.title = NSLocalizedString(@"Settings", @"Title of options screen");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneAction:)];
    // Setup the Switches
    self.alphabeticalTagSortSwitch = [UISwitch new];
    [self.alphabeticalTagSortSwitch addTarget:self
                                        action:@selector(tagSortSwitchDidChangeValue:)
                              forControlEvents:UIControlEventValueChanged];

    self.condensedNoteListSwitch = [UISwitch new];
    [self.condensedNoteListSwitch addTarget:self
                                     action:@selector(condensedSwitchDidChangeValue:)
                           forControlEvents:UIControlEventValueChanged];

    self.biometrySwitch = [UISwitch new];
    [self.biometrySwitch addTarget:self
                           action:@selector(touchIdSwitchDidChangeValue:)
                 forControlEvents:UIControlEventValueChanged];

    self.sustainerIconSwitch = [UISwitch new];
    [self.sustainerIconSwitch addTarget:self
                                 action:@selector(sustainerSwitchDidChangeValue:)
                       forControlEvents:UIControlEventValueChanged];

    self.pinTimeoutPickerView = [UIPickerView new];
    self.pinTimeoutPickerView.delegate = self;
    self.pinTimeoutPickerView.dataSource = self;
    [self.pinTimeoutPickerView selectRow:[[NSUserDefaults standardUserDefaults] integerForKey:kPinTimeoutPreferencesKey] inComponent:0 animated:NO];
    
    self.doneToolbar = [UIToolbar new];
    self.doneToolbar.barStyle = UIBarStyleDefault;
    self.doneToolbar.translucent = NO;
    [self.doneToolbar sizeToFit];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Done", @"Done toolbar button")                                                                                    style:UIBarButtonItemStylePlain target:self                                                                 action:@selector(pinTimeoutDoneAction:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace                                                                                    target:nil action:nil];
    
    fixedSpace.width = self.doneToolbar.frame.size.width;
    [self.doneToolbar setItems:[NSArray arrayWithObjects:fixedSpace, doneButtonItem, nil]];
    
    self.pinTimeoutTextField = [UITextField new];
    self.pinTimeoutTextField.frame = CGRectMake(0, 0, 0, 0);
    self.pinTimeoutTextField.inputView = self.pinTimeoutPickerView;
    self.pinTimeoutTextField.inputAccessoryView = self.doneToolbar;
    [self.view addSubview:self.pinTimeoutTextField];
    
    // Listen to Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChange)
                                                 name:SPSimplenoteThemeChangedNotification
                                               object:nil];

    [self refreshThemeStyles];

    self.tableView.sectionHeaderHeight = CGFLOAT_MIN;
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notifications

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if INTERNAL_DISTRIBUTION
    return SPOptionsViewSectionsCount;
#else
    return SPOptionsViewSectionsCount - 1;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SPOptionsViewSectionsNotes: {
            return SPOptionsNotesRowCount;
        }
            
        case SPOptionsViewSectionsTags: {
            return SPOptionsTagsRowCount;
        }
            
        case SPOptionsViewSectionsAppearance: {
            return SPOptionsAppearanceRowCount;
        }

        case SPOptionsViewSectionsSustainer: {
            return [self isActiveSustainer] ? SPOptionsAccountSustainerCount : 0;
        }

        case SPOptionsViewSectionsSecurity: {
            int rowsToRemove = [self isBiometryAvailable] ? 0 : 1;
            int disabledPinLockRows = [self isBiometryAvailable] ? 2 : 1;
            return [self isPinLockEnabled] ? SPOptionsSecurityRowRowCount - rowsToRemove : disabledPinLockRows;
        }

        case SPOptionsViewSectionsDelete: {
            return SPOptionsDeleteRowCount;
        }
            
        case SPOptionsViewSectionsAbout: {
            return SPOptionsAboutRowCount;
        }
            
        case SPOptionsViewSectionsHelp: {
            return SPOptionsHelpRowCount;
        }
            
        case SPOptionsViewSectionsDebug: {
            return SPOptionsDebugRowCount;
        }

        case SPOptionsViewSectionsAccount: {
            return SPOptionsAccountRowCount;
        }

        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SPOptionsViewSectionsNotes:
            return NSLocalizedString(@"Notes", nil);
            
        case SPOptionsViewSectionsTags:
            return NSLocalizedString(@"Tags", nil);
            
        case SPOptionsViewSectionsAppearance:
            return NSLocalizedString(@"Appearance", nil);

        case SPOptionsViewSectionsSustainer:
            if ([self isActiveSustainer]) {
                return NSLocalizedString(@"Sustainer Thank You", nil);
            }
            break;

        case SPOptionsViewSectionsSecurity:
            return NSLocalizedString(@"Security", nil);

        case SPOptionsViewSectionsAccount:
            return NSLocalizedString(@"Account", nil);

        default:
            break;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
#if INTERNAL_DISTRIBUTION
    if (section == SPOptionsViewSectionsDebug) {
        return [[NSString alloc] initWithFormat:@"Beta Distribution Channel\nv%@ (%@)", [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]], [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
    }
#endif

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch(section) {
        case SPOptionsViewSectionsSustainer:
            return [self isActiveSustainer] ? SPSettingsTableViewSpacing : CGFLOAT_MIN;
        default:
            return SPSettingsTableViewSpacing;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch(section) {
        case SPOptionsViewSectionsSustainer:
            return [self isActiveSustainer] ? SPSettingsTableViewSpacing : CGFLOAT_MIN;
        default:
            return SPSettingsTableViewSpacing;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self refreshTableViewCellStyle:cell];
    
    switch (indexPath.section) {
        case SPOptionsViewSectionsNotes: {
            
            switch (indexPath.row) {
                case SPOptionsPreferencesRowSort: {
                    cell.textLabel.text = NSLocalizedString(@"Sort Order", @"Option to sort notes in the note list alphabetically. The default is by modification date");
                    cell.detailTextLabel.text = [[Options shared] listSortModeDescription];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.tag = kTagNoteListSort;
                    break;
                }
                case SPOptionsPreferencesRowCondensed: {
                    cell.textLabel.text = NSLocalizedString(@"Condensed Note List", @"Option to make the note list show only 1 line of text. The default is 3.");

                    self.condensedNoteListSwitch.on = [[Options shared] condensedNotesList];

                    cell.accessoryView = self.condensedNoteListSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = kTagCondensedNoteList;
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
            
        } case SPOptionsViewSectionsTags: {
            switch (indexPath.row) {
                case SPOptionsPreferencesRowTagSort: {
                    cell.textLabel.text = NSLocalizedString(@"Sort Alphabetically", @"Option to sort tags alphabetically. The default is by manual ordering.");
                    
                    [self.alphabeticalTagSortSwitch setOn:[self alphabeticalTagSortPref]];
                    
                    cell.accessoryView = self.alphabeticalTagSortSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = kTagTagsListSort;
                    break;
                }
                
                default:
                    break;
            }
            
            break;
        }
        
        case SPOptionsViewSectionsAppearance: {
            switch (indexPath.row) {
                case SPOptionsPreferencesRowTheme: {
                    cell.textLabel.text = NSLocalizedString(@"Theme", @"Option to enable the dark app theme.");
                    cell.detailTextLabel.text = [[Options shared] themeDescription];
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.tag = kTagTheme;
                    break;
                }
                    
                default:
                    break;
            }
            
            break;
        }

        case SPOptionsViewSectionsSustainer: {
            switch (indexPath.row) {
                case SPOptionsAccountSustainerIcon: {
                    cell.textLabel.text = NSLocalizedString(@"Sustainer App Icon", @"Switch app icon");
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;

                    cell.accessoryView = self.sustainerIconSwitch;
                    cell.tag = kTagSustainerIcon;
                    break;

                }

                default:
                    break;
            }

            break;
        }

        case SPOptionsViewSectionsSecurity: {
            switch (indexPath.row) {
                case SPOptionsSecurityRowRowPasscode: {
                    cell.textLabel.text = NSLocalizedString(@"Passcode", @"A 4-digit code to lock the app when it is closed");
                    
                    if ([self isPinLockEnabled])
                        cell.detailTextLabel.text = NSLocalizedString(@"On", nil);
                    else
                        cell.detailTextLabel.text = NSLocalizedString(@"Off", nil);
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.tag = kTagPasscode;

                    cell.accessibilityIdentifier = @"passcode-cell";
                    
                    break;
                }
                case SPOptionsSecurityRowRowBiometry: {
                    if ([self isBiometryAvailable]) {
                        cell.textLabel.text = [self biometryTitle];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;

                        self.biometrySwitch.on = SPPinLockManager.shared.shouldUseBiometry;
                        cell.accessoryView = self.biometrySwitch;
                        cell.tag = kTagTouchID;
                        
                        break;
                    }
                    
                    // No break here so we intentionally render the Timeout cell if biometry is disabled
                }
                case SPOptionsSecurityRowTimeout: {
                    cell.textLabel.text = NSLocalizedString(@"Lock Timeout", @"Setting for when the passcode lock should enable");
                    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                    cell.accessoryView = nil;
                    cell.tag = kTagTimeout;
                    
                    NSInteger timeoutPref = [[NSUserDefaults standardUserDefaults] integerForKey:kPinTimeoutPreferencesKey];
                    [cell.detailTextLabel setText:timeoutPickerOptions[timeoutPref]];
                    
                    break;
                }
                    
                default:
                    break;
            }
            
            break;

        } case SPOptionsViewSectionsAccount: {

            switch (indexPath.row) {
                case SPOptionsAccountRowDescription: {
                    cell.textLabel.text = NSLocalizedString(@"Username", @"A user's Simplenote account");
                    cell.detailTextLabel.text = [SPAppDelegate sharedDelegate].simperium.user.email;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case SPOptionsAccountRowPrivacy: {
                    cell.textLabel.text = NSLocalizedString(@"Privacy Settings", @"Privacy Settings");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                case SPOptionsAccountRowLogout: {
                    cell.textLabel.text = NSLocalizedString(@"Log Out", @"Log out of the active account in the app");
                    cell.textLabel.textColor = [UIColor simplenoteTintColor];
                    break;
                }
                default:
                    break;
            }
            
            break;

        } case SPOptionsViewSectionsDelete: {
            
            switch (indexPath.row) {
                case SPOptionsDeleteRowTitle: {
                    cell.textLabel.text = NSLocalizedString(@"Delete Account", @"Display Delete Account Alert");
                    cell.textLabel.textColor = [UIColor simplenoteRedButtonColor];
                    break;
                }
            }
            
            break;
        } case SPOptionsViewSectionsAbout: {

            switch (indexPath.row) {
                case SPOptionsAboutRowTitle: {
                    cell.textLabel.text = NSLocalizedString(@"About", @"Display app about screen");
                    break;
                }
            }

            break;
        } case SPOptionsViewSectionsHelp: {
            
            switch (indexPath.row) {
                case SPOptionsHelpRowTitle: {
                    cell.textLabel.text = NSLocalizedString(@"Help", @"Display help web page");
                    break;
                }
            }
            
            break;
        } case SPOptionsViewSectionsDebug: {

            switch (indexPath.row) {
                case SPOptionsDebugRowStats: {
                    cell.textLabel.text = NSLocalizedString(@"Debug", @"Display internal debug status");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
            
            break;
        }

        default:
            break;
    }
    
    
    
    return cell;
}

- (BOOL)isPinLockEnabled {
    return SPPinLockManager.shared.isEnabled;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    switch (indexPath.section) {

        case SPOptionsViewSectionsNotes: {
            switch (cell.tag) {
                case kTagNoteListSort: {
                    SPSortOrderViewController *controller = [SPSortOrderViewController new];
                    controller.selectedMode = [[Options shared] listSortMode];
                    controller.onChange = ^(SortMode newMode) {
                        [[Options shared] setListSortMode:newMode];
                    };

                    [self.navigationController pushViewController:controller animated:true];
                    break;
                }
            }
            break;
        }

        case SPOptionsViewSectionsAppearance: {
            switch (cell.tag) {
                case kTagTheme: {
                    SPThemeViewController *controller = [SPThemeViewController new];
                    controller.selectedTheme = [[Options shared] theme];
                    controller.onChange = ^(Theme newTheme) {
                        [[Options shared] setTheme:newTheme];
                    };

                    [self.navigationController pushViewController:controller animated:true];
                    break;
                }
            }
            break;
        }

        case SPOptionsViewSectionsSecurity: {
            
            switch (cell.tag) {
                case kTagPasscode: {
                    [self showPinLockViewController];
                    break;
                case kTagTimeout:
                    [self.pinTimeoutTextField becomeFirstResponder];
                    break;
                }
            }
            
            break;

        } case SPOptionsViewSectionsAccount: {
            
            switch (indexPath.row) {
                case SPOptionsAccountRowPrivacy: {
                    SPPrivacyViewController *test = [[SPPrivacyViewController alloc] initWithStyle:UITableViewStyleGrouped];
                    [self.navigationController pushViewController:test animated:true];
                    break;
                }

                case SPOptionsAccountRowLogout: {
                    [self signOutAction:nil];
                    break;
                }
                default:
                    break;
            }
            
            break;

        } case SPOptionsViewSectionsDelete: {
            switch (indexPath.row) {
                case SPOptionsDeleteRowTitle: {
                    [self deleteAccountWasPressed];
                    break;
                }
            }

            break;
        } case SPOptionsViewSectionsAbout: {
            switch (indexPath.row) {
                case SPOptionsAboutRowTitle: {
                    SPAboutViewController *aboutController = [[SPAboutViewController alloc] init];
                    aboutController.modalPresentationStyle = UIModalPresentationFormSheet;
                    [[self navigationController] presentViewController:aboutController animated:YES completion:nil];
                    break;
                }
            }
            
            break;
        } case SPOptionsViewSectionsHelp: {
            switch (indexPath.row) {
                case SPOptionsHelpRowTitle: {
                    NSURL *url = [NSURL URLWithString:@"https://simplenote.com/help"];
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];

                    break;
                }
            }
            
            break;
        } case SPOptionsViewSectionsDebug: {
            switch (indexPath.row) {
                case SPOptionsDebugRowStats: {
                    [self showDebugInformation];
                    break;
                }
            }
            
            break;
        }
            

        default:
            break;
    }
    
	[cell setSelected:NO animated:NO];
}


- (void)refreshTableViewCellStyle:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor simplenoteTableViewCellBackgroundColor];
    cell.selectedBackgroundView.backgroundColor = [UIColor simplenoteLightBlueColor];
    cell.textLabel.textColor = [UIColor simplenoteTextColor];
    cell.detailTextLabel.textColor = [UIColor simplenoteSecondaryTextColor];
}


#pragma mark - Helpers

- (void)showDebugInformation
{
    SPDebugViewController *debugViewController = [SPDebugViewController newDebugViewController];
    [self.navigationController pushViewController:debugViewController animated:YES];
    
}

- (void)signOutAction:(id)sender
{
    // Safety first: Check for unsynced notes before they are deleted!
    Simperium *simperium = [[SPAppDelegate sharedDelegate] simperium];

    if ([StatusChecker hasUnsentChanges:simperium] == false) {
        [SPTracker trackUserSignedOut];
        [[SPAppDelegate sharedDelegate] logoutAndReset:sender];
        return;
    }

    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Unsynced Notes Detected", @"Alert title displayed in settings when an account has unsynced notes")
                                message:NSLocalizedString(@"Signing out will delete any unsynced notes. You can verify your synced notes by signing in to the Web App.", @"Alert message displayed when an account has unsynced notes")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* signOutAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Delete Notes", @"Verb: Delete notes and log out of the app")
                                    style:UIAlertActionStyleDestructive
                                    handler:^(UIAlertAction * action) {
                                        [SPTracker trackUserSignedOut];
                                        [[SPAppDelegate sharedDelegate] logoutAndReset:sender];
                                    }];
    UIAlertAction* viewWebAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"Visit Web App", @"Visit app.simplenote.com in the browser")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.simplenote.com"] options:@{} completionHandler:nil];
                                    }];
    UIAlertAction* cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Verb, cancel an alert dialog")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];

                                   }];
    [alert addAction:signOutAction];
    [alert addAction:viewWebAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Switches

- (void)condensedSwitchDidChangeValue:(UISwitch *)sender
{
    BOOL isOn = [(UISwitch *)sender isOn];

    [[Options shared] setCondensedNotesList:isOn];
    [SPTracker trackSettingsListCondensedEnabled:isOn];
}

- (void)tagSortSwitchDidChangeValue:(UISwitch *)sender
{
    BOOL isOn = [(UISwitch *)sender isOn];
    NSNumber *notificationObject = [NSNumber numberWithBool:isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPAlphabeticalTagSortPref];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAlphabeticalTagSortPreferenceChangedNotification
                                                        object:notificationObject];
}

- (void)touchIdSwitchDidChangeValue:(UISwitch *)sender
{
    SPPinLockManager.shared.shouldUseBiometry = sender.on;

    if (![self isPinLockEnabled] && [self.biometrySwitch isOn]) {
        UIAlertController* alert = [self pinLockRequiredAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)sustainerSwitchDidChangeValue:(UISwitch *)sender
{
    BOOL isOn = [(UISwitch *)sender isOn];

    NSString *iconName = isOn ? SPSustainerAppIconName : nil;
    [UIApplication.sharedApplication setAlternateIconName:iconName completionHandler:nil];
}

- (UIAlertController*)pinLockRequiredAlert
{
    NSString *alertTitleTemplate = NSLocalizedString(@"To enable %1$@, you must have a passcode setup first.",
                                                     @"Prompt to setup passcode before biomtery lock. Parameters: %1$@ - biometry type (Face ID or Touch ID");
    NSString *alertTitle = [NSString stringWithFormat:alertTitleTemplate, self.biometryTitle];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.biometryTitle
                                                                   message:alertTitle
                                                            preferredStyle:UIAlertControllerStyleAlert];

    NSString *setupTitle = NSLocalizedString(@"Set up Passcode", @"Setup a passcode action button");
    [alert addActionWithTitle:setupTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showPinLockViewController];
    }];

    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel action button");
    [alert addCancelActionWithTitle:cancelTitle handler:^(UIAlertAction * action) {
        [self.biometrySwitch setOn:NO];
    }];

    return alert;
}


#pragma mark - Darkness

- (void)themeDidChange
{
    [self refreshThemeStyles];
    [self.tableView reloadData];
}

- (void)refreshThemeStyles
{
    // Reload Switch Styles
    NSArray *switches       = @[ _condensedNoteListSwitch, _alphabeticalTagSortSwitch, _biometrySwitch ];
    
    for (UISwitch *theSwitch in switches) {
        theSwitch.onTintColor   = [UIColor simplenoteSwitchOnTintColor];
        theSwitch.tintColor     = [UIColor simplenoteSwitchTintColor];
    }

    UIColor *tintColor = [UIColor simplenoteTintColor];
    UIColor *backgroundColor = [UIColor simplenoteBackgroundColor];

    [self.pinTimeoutPickerView setBackgroundColor:backgroundColor];
    [self.doneToolbar setTintColor:tintColor];
    [self.doneToolbar setBarTintColor:backgroundColor];
    
    // Refresh the Table
    [self.tableView applySimplenoteGroupedStyle];
}


#pragma mark - Preferences

- (BOOL)alphabeticalTagSortPref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalTagSortPref];
}


#pragma mark - Picker view delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [timeoutPickerOptions count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.pinTimeoutTextField setText:timeoutPickerOptions[row]];
    
    [[NSUserDefaults standardUserDefaults] setInteger:row forKey:kPinTimeoutPreferencesKey];
    [self.tableView reloadData];
}

- (void)pinTimeoutDoneAction:(id)sender
{
    [self.pinTimeoutTextField resignFirstResponder];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *attributes = @{
        NSForegroundColorAttributeName: [UIColor simplenoteTextColor]
    };

    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:timeoutPickerOptions[row] attributes:attributes];
    
    return attributedTitle;
}

@end
