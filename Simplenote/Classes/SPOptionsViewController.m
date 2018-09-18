//
//  SPOptionsViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 7/22/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPOptionsViewController.h"
#import "SPAppDelegate.h"
#import "SPConstants.h"
#import "DTPinLockController.h"
#import "UIView+ImageRepresentation.h"
#import "UITableView+Styling.h"
#import "VSThemeManager.h"
#import "StatusChecker.h"
#import "SPTracker.h"
#import "SPDebugViewController.h"
#import "UIDevice+Extensions.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "Simplenote-Swift.h"
#import "Simperium+Simplenote.h"

NSString *const SPCondensedNoteListPref                             = @"SPCondensedNoteListPref";
NSString *const SPCondensedNoteListPreferenceChangedNotification    = @"SPCondensedNoteListPreferenceChangedNotification";
NSString *const SPAlphabeticalSortPref                              = @"SPAlphabeticalSortPref";
NSString *const SPAlphabeticalSortPreferenceChangedNotification     = @"SPAlphabeticalSortPreferenceChangedNotification";
NSString *const SPThemePref                                         = @"SPThemePref";

@interface SPOptionsViewController ()
@property (nonatomic, strong) UISwitch      *condensedNoteListSwitch;
@property (nonatomic, strong) UISwitch      *alphabeticalSortSwitch;
@property (nonatomic, strong) UISwitch      *themeListSwitch;
@property (nonatomic, strong) UISwitch      *biometrySwitch;
@property (nonatomic, strong) UISwitch      *analyticsSwitch;
@property (nonatomic, assign) BOOL          biometryIsAvailable;
@property (nonatomic, copy) NSString        *biometryTitle;
@property (nonatomic, strong) UITextField   *pinTimeoutTextField;
@property (nonatomic, strong) UIPickerView  *pinTimeoutPickerView;
@property (nonatomic, strong) UIToolbar     *doneToolbar;
@end

@implementation SPOptionsViewController {
    NSArray *timeoutPickerOptions;
}

#define kTagAlphabeticalSort    1
#define kTagCondensedNoteList   2
#define kTagTheme               3
#define kTagPasscode            4
#define kTagTimeout             5
#define kTagTouchID             6

typedef NS_ENUM(NSInteger, SPOptionsViewSections) {
    SPOptionsViewSectionsPreferences    = 0,
    SPOptionsViewSectionsSecurity       = 1,
    SPOptionsViewSectionsPrivacy        = 2,
    SPOptionsViewSectionsAccount        = 3,
    SPOptionsViewSectionsAbout          = 4,
    SPOptionsViewSectionsDebug          = 5,
    SPOptionsViewSectionsCount          = 6
};

typedef NS_ENUM(NSInteger, SPOptionsAccountRow) {
    SPOptionsAccountRowDescription      = 0,
    SPOptionsAccountRowLogout           = 1,
    SPOptionsAccountRowCount            = 2
};

typedef NS_ENUM(NSInteger, SPOptionsPrivacyRow) {
    SPOptionsPrivacyRowSwitch           = 0,
    SPOptionsPrivacyRowCount            = 1
};

typedef NS_ENUM(NSInteger, SPOptionsPreferencesRow) {
    SPOptionsPreferencesRowSort         = 0,
    SPOptionsPreferencesRowCondensed    = 1,
    SPOptionsPreferencesRowTheme        = 2,
    SPOptionsPreferencesRowCount        = 3
};

typedef NS_ENUM(NSInteger, SPOptionsSecurityRow) {
    SPOptionsSecurityRowRowPasscode     = 0,
    SPOptionsSecurityRowRowBiometry     = 1,
    SPOptionsSecurityRowTimeout         = 2,
    SPOptionsSecurityRowRowCount        = 3
};

typedef NS_ENUM(NSInteger, SPOptionsAboutRow) {
    SPOptionsAboutRowTitle              = 0,
    SPOptionsAboutRowCount              = 1
};

typedef NS_ENUM(NSInteger, SPOptionsDebugRow) {
    SPOptionsDebugRowStats              = 0,
    SPOptionsDebugRowCount              = 1
};

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewStyle)style
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
    self.alphabeticalSortSwitch = [UISwitch new];
    [self.alphabeticalSortSwitch addTarget:self
                                    action:@selector(sortSwitchDidChangeValue:)
                          forControlEvents:UIControlEventValueChanged];

    self.condensedNoteListSwitch = [UISwitch new];
    [self.condensedNoteListSwitch addTarget:self
                                     action:@selector(condensedSwitchDidChangeValue:)
                           forControlEvents:UIControlEventValueChanged];

    self.themeListSwitch = [UISwitch new];
    [self.themeListSwitch addTarget:self
                             action:@selector(themeSwitchDidChangeValue:)
                   forControlEvents:UIControlEventValueChanged];

    self.biometrySwitch = [UISwitch new];
    [self.biometrySwitch addTarget:self
                           action:@selector(touchIdSwitchDidChangeValue:)
                 forControlEvents:UIControlEventValueChanged];

    self.analyticsSwitch = [UISwitch new];
    [self.analyticsSwitch addTarget:self
                             action:@selector(analyticsSwitchDidChangeValue:)
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
    
    // Listen to Theme Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeDidChange)
                                                 name:VSThemeManagerThemeDidChangeNotification
                                               object:nil];

    [self refreshThemeStyles];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkForBiometry];
    
    [self.tableView reloadData];
}

- (void)checkForBiometry
{
    if ([LAContext class]) {
        LAContext *context = [LAContext new];
        NSError *error;
        if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                error:&error]) {
            self.biometryIsAvailable = YES;

            BOOL faceIDAvailable = NO;
            
            if (@available(iOS 11.0, *)) {
                if (context.biometryType == LABiometryTypeFaceID) {
                    faceIDAvailable = YES;
                }
            }

            self.biometryTitle = (faceIDAvailable) ?
                NSLocalizedString(@"Face ID", @"Offer to enable Face ID support if available and passcode is on.") :
                NSLocalizedString(@"Touch ID", @"Offer to enable Touch ID support if available and passcode is on.");
        }
    }
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


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
        case SPOptionsViewSectionsAccount: {
            return SPOptionsAccountRowCount;
        }
            
        case SPOptionsViewSectionsPreferences: {
            return SPOptionsPreferencesRowCount;
        }
            
        case SPOptionsViewSectionsSecurity: {
            int rowsToRemove = self.biometryIsAvailable ? 0 : 1;
            int disabledPinLockRows = [self biometryIsAvailable] ? 2 : 1;
            return [self pinLockIsEnabled] ? SPOptionsSecurityRowRowCount - rowsToRemove : disabledPinLockRows;
        }

        case SPOptionsViewSectionsPrivacy: {
            return SPOptionsPrivacyRowCount;
        }
            
        case SPOptionsViewSectionsAbout: {
            return SPOptionsAboutRowCount;
        }
            
        case SPOptionsViewSectionsDebug: {
            return SPOptionsDebugRowCount;
        }
            
        default:
            break;
    }
    
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SPOptionsViewSectionsPreferences:
            return NSLocalizedString(@"Preferences", nil);
            
        case SPOptionsViewSectionsSecurity:
            return NSLocalizedString(@"Security", nil);

        case SPOptionsViewSectionsPrivacy:
            return NSLocalizedString(@"Privacy", nil);

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

    if (section == SPOptionsViewSectionsPrivacy) {
        return NSLocalizedString(@"Help us improve Simplenote by sharing usage data with our analytics tool.", nil);
    }
    
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self refreshTableViewCellStyle:cell];
    
    switch (indexPath.section) {
        case SPOptionsViewSectionsPreferences:{
            
            switch (indexPath.row) {
                case SPOptionsPreferencesRowSort: {
                    cell.textLabel.text = NSLocalizedString(@"Sort Notes Alphabetically", @"Option to sort notes in the note list alphabetically. The default is by modification date");
                    
                    [self.alphabeticalSortSwitch setOn:[self alphabeticalSortPref]];
                    
                    cell.accessoryView = self.alphabeticalSortSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = kTagAlphabeticalSort;
                    break;
                }
                case SPOptionsPreferencesRowCondensed: {
                    cell.textLabel.text = NSLocalizedString(@"Condensed Note List", @"Option to make the note list show only 1 line of text. The default is 3.");
                    
                    [self.condensedNoteListSwitch setOn:[self condesedNoteListPref]];
                    
                    cell.accessoryView = self.condensedNoteListSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = kTagCondensedNoteList;
                    break;
                }
                case SPOptionsPreferencesRowTheme: {
                    cell.textLabel.text = NSLocalizedString(@"Dark Theme", @"Option to enable the dark app theme.");

                    [self.themeListSwitch setOn:[self themePref]];
                    
                    cell.accessoryView = self.themeListSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = kTagTheme;
                    break;
                }
            }
            break;
            
        } case SPOptionsViewSectionsSecurity: {
            switch (indexPath.row) {
                case SPOptionsSecurityRowRowPasscode: {
                    cell.textLabel.text = NSLocalizedString(@"Passcode", @"A 4-digit code to lock the app when it is closed");
                    
                    if ([self pinLockIsEnabled])
                        cell.detailTextLabel.text = NSLocalizedString(@"On", nil);
                    else
                        cell.detailTextLabel.text = NSLocalizedString(@"Off", nil);
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.tag = kTagPasscode;
                    
                    break;
                }
                case SPOptionsSecurityRowRowBiometry: {
                    if ([self biometryIsAvailable]) {
                        cell.textLabel.text = self.biometryTitle;
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        BOOL isBiometryOn = [[SPAppDelegate sharedDelegate] allowBiometryInsteadOfPin];
                        
                        self.biometrySwitch.on = isBiometryOn;
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
        } case SPOptionsViewSectionsAccount:{
            
            switch (indexPath.row) {
                case SPOptionsAccountRowDescription: {
                    cell.textLabel.text = NSLocalizedString(@"Account", @"A user's Simplenote account");
                    cell.detailTextLabel.text = [SPAppDelegate sharedDelegate].simperium.user.email;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                case SPOptionsAccountRowLogout: {
                    cell.textLabel.text = NSLocalizedString(@"Sign Out", @"Sign out of the active account in the app");
                    break;
                }
                default:
                    break;
            }
            
            break;
        } case SPOptionsViewSectionsPrivacy: {
            switch (indexPath.row) {
                case SPOptionsPrivacyRowSwitch: {
                    cell.textLabel.text = NSLocalizedString(@"Share Analytics", @"Option to disable Analytics.");

                    [self.analyticsSwitch setOn:[self analyticsEnabledPref]];

                    cell.accessoryView = self.analyticsSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (BOOL)pinLockIsEnabled {
    NSString *pin = [[SPAppDelegate sharedDelegate] getPin:NO];
    
    return pin != nil && pin.length > 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
    switch (indexPath.section) {
            
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
                case SPOptionsAccountRowLogout: {
                    [self signOutAction:nil];
                    break;
                }
                default:
                    break;
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
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    cell.backgroundColor = [theme colorForKey:@"backgroundColor"];
    cell.selectedBackgroundView.backgroundColor = [theme colorForKey:@"noteCellBackgroundSelectionColor"];
    cell.textLabel.textColor = [theme colorForKey:@"tableViewTextLabelColor"];
    cell.detailTextLabel.textColor = [theme colorForKey:@"tableViewDetailTextLabelColor"];
}


- (void)showPinLockViewController
{
    NSString *pin = [[SPAppDelegate sharedDelegate] getPin:NO];
    PinLockControllerMode mode = pin.length ? PinLockControllerModeRemovePin : PinLockControllerModeSetPin;
    
    DTPinLockController *controller = [[DTPinLockController alloc] initWithMode:mode];
    controller.pinLockDelegate = self;
    controller.pin = pin;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:controller
                                            animated:YES
                                          completion:nil];
    
    if ([UIDevice isPad]) {
        [controller fixLayout];
    }
}


#pragma mark - PinLock Delegate

- (void)pinLockController:(DTPinLockController *)pinLockController didFinishSelectingNewPin:(NSString *)newPin
{
    [SPTracker trackSettingsPinlockEnabled:YES];
    
    [[SPAppDelegate sharedDelegate] setPin:newPin];
    [self.tableView reloadData];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)pinLockControllerDidFinishRemovingPin
{
    [SPTracker trackSettingsPinlockEnabled:NO];
    
    [[SPAppDelegate sharedDelegate] removePin];
    [[SPAppDelegate sharedDelegate] setAllowBiometryInsteadOfPin:NO];
    
    [self.tableView reloadData];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (void)pinLockControllerDidCancel
{
    // Make sure the UI is consistent
    NSString *pin = [[SPAppDelegate sharedDelegate] getPin:false];
    if (pin.length == 0) {
        [[SPAppDelegate sharedDelegate] setAllowBiometryInsteadOfPin:NO];
    }
    
    [self.tableView reloadData];
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
                                    actionWithTitle:NSLocalizedString(@"Delete Notes", @"Verb: Delete notes and sign out of the app")
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
    NSNumber *notificationObject = [NSNumber numberWithBool:isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPCondensedNoteListPref];

    [SPTracker trackSettingsListCondensedEnabled:isOn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPCondensedNoteListPreferenceChangedNotification
                                                        object:notificationObject];
}


- (void)sortSwitchDidChangeValue:(UISwitch *)sender
{
    BOOL isOn = [(UISwitch *)sender isOn];
    NSNumber *notificationObject = [NSNumber numberWithBool:isOn];
    
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPAlphabeticalSortPref];
    
    [SPTracker trackSettingsAlphabeticalSortEnabled:isOn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SPAlphabeticalSortPreferenceChangedNotification
                                                        object:notificationObject];
}

- (void)themeSwitchDidChangeValue:(UISwitch *)sender
{
    BOOL isOn = [(UISwitch *)sender isOn];
    [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:SPThemePref];
    [[VSThemeManager sharedManager] swapTheme:(isOn) ? @"dark" : @"default"];
}

- (void)touchIdSwitchDidChangeValue:(UISwitch *)sender
{
    [[SPAppDelegate sharedDelegate] setAllowBiometryInsteadOfPin:sender.on];
    
    NSString *pin = [[SPAppDelegate sharedDelegate] getPin:NO];
    if (pin.length == 0) {
        [self showPinLockViewController];
    }
}

- (void)analyticsSwitchDidChangeValue:(UISwitch *)sender
{
    Simperium *simperium = [[SPAppDelegate sharedDelegate] simperium];
    Preferences *preferences = [simperium preferencesObject];

    preferences.analytics_enabled = @(sender.isOn);
    [simperium save];
}

#pragma mark - Darkness

- (void)themeDidChange
{
    [self refreshThemeStyles];
    [self reloadAppearance];
    [self.tableView reloadData];
}

- (void)refreshThemeStyles
{
    // Reload Switch Styles
    VSTheme *theme          = [[VSThemeManager sharedManager] theme];
    NSArray *switches       = @[ _condensedNoteListSwitch, _alphabeticalSortSwitch, _themeListSwitch, _biometrySwitch, _analyticsSwitch ];
    
    for (UISwitch *theSwitch in switches) {
        theSwitch.onTintColor   = [theme colorForKey:@"switchOnTintColor"];
        theSwitch.tintColor     = [theme colorForKey:@"switchTintColor"];
    }
    
    [self.pinTimeoutPickerView setBackgroundColor:[theme colorForKey:@"backgroundColor"]];
    [self.doneToolbar setTintColor:[theme colorForKey:@"tintColor"]];
    [self.doneToolbar setBarTintColor:[theme colorForKey:@"backgroundColor"]];
    
    // Refresh the Table
    [self.tableView applyDefaultGroupedStyling];
}

- (void)reloadAppearance
{
    // HACK:
    // Yes, another one. Reference: http://stackoverflow.com/questions/17070582/using-uiappearance-and-switching-themes
    // This is required, so UINavigationBar picks up the new style
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        for (UIView *view in window.subviews) {
            [view removeFromSuperview];
            [window addSubview:view];
        }
    }
}


#pragma mark - Preferences

- (BOOL)alphabeticalSortPref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SPAlphabeticalSortPref];
}

- (BOOL)condesedNoteListPref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SPCondensedNoteListPref];
}

- (BOOL)themePref
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:SPThemePref];
}

- (BOOL)analyticsEnabledPref
{
    Simperium *simperium = [[SPAppDelegate sharedDelegate] simperium];
    NSNumber *enabled = [[simperium preferencesObject] analytics_enabled];

    return enabled == nil || [enabled boolValue] == true;
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
    VSTheme *theme = [[VSThemeManager sharedManager] theme];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[theme colorForKey:@"textColor"]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:timeoutPickerOptions[row] attributes:attributes];
    
    return attributedTitle;
}

@end
