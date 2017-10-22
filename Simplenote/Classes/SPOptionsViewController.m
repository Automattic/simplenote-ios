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
#import "SPTracker.h"
#import "SPDebugViewController.h"
#import "UIDevice+Extensions.h"
#import <LocalAuthentication/LocalAuthentication.h>


NSString *const SPCondensedNoteListPref                             = @"SPCondensedNoteListPref";
NSString *const SPCondensedNoteListPreferenceChangedNotification    = @"SPCondensedNoteListPreferenceChangedNotification";
NSString *const SPAlphabeticalSortPref                              = @"SPAlphabeticalSortPref";
NSString *const SPAlphabeticalSortPreferenceChangedNotification     = @"SPAlphabeticalSortPreferenceChangedNotification";
NSString *const SPThemePref                                         = @"SPThemePref";

@interface SPOptionsViewController ()
@property (nonatomic, strong) UISwitch  *condensedNoteListSwitch;
@property (nonatomic, strong) UISwitch  *alphabeticalSortSwitch;
@property (nonatomic, strong) UISwitch  *themeListSwitch;
@property (nonatomic, strong) UISwitch  *biometrySwitch;
@property (nonatomic, assign) BOOL      biometryIsAvailable;
@property (nonatomic, copy) NSString    *biometryTitle;
@end

@implementation SPOptionsViewController

#define kTagAlphabeticalSort    1
#define kTagCondensedNoteList   2
#define kTagTheme               3
#define kTagPasscode            4
#define kTagTouchID             5

typedef NS_ENUM(NSInteger, SPOptionsViewSections) {
    SPOptionsViewSectionsPreferences    = 0,
    SPOptionsViewSectionsSecurity       = 1,
    SPOptionsViewSectionsAccount        = 2,
    SPOptionsViewSectionsDebug          = 3,
    SPOptionsViewSectionsCount          = 4
};

typedef NS_ENUM(NSInteger, SPOptionsAccountRow) {
    SPOptionsAccountRowDescription      = 0,
    SPOptionsAccountRowLogout           = 1,
    SPOptionsAccountRowCount            = 2
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
    SPOptionsSecurityRowRowCount        = 2
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
#if BETA_DISTRIBUTION
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
            return self.biometryIsAvailable ? SPOptionsSecurityRowRowCount : SPOptionsSecurityRowRowCount - 1;
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
            
        default:
            break;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
#if BETA_DISTRIBUTION
    if (section == SPOptionsViewSectionsDebug) {
        return [[NSString alloc] initWithFormat:@"Beta Distribution Channel\nv%@ (%@)", [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]], [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey]];
    }
#endif
    
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
                    
                    NSString *pin = [[SPAppDelegate sharedDelegate] getPin:NO];
                    
                    if (pin != nil && pin.length > 0)
                        cell.detailTextLabel.text = NSLocalizedString(@"On", nil);
                    else
                        cell.detailTextLabel.text = NSLocalizedString(@"Off", nil);
                    
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.tag = kTagPasscode;
                    
                    break;
                }
                case SPOptionsSecurityRowRowBiometry: {
                    cell.textLabel.text = self.biometryTitle;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;

                    BOOL isBiometryOn = [[SPAppDelegate sharedDelegate] allowBiometryInsteadOfPin];

                    self.biometrySwitch.on = isBiometryOn;
                    cell.accessoryView = self.biometrySwitch;
                    cell.tag = kTagTouchID;
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
        } case SPOptionsViewSectionsDebug: {

            switch (indexPath.row) {
                case SPOptionsDebugRowStats: {
                    cell.textLabel.text = NSLocalizedString(@"Debug", @"Display internal debug status");
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
            }
        }

        default:
            break;
    }
    
    
    
    return cell;
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
        } case SPOptionsViewSectionsDebug: {
            switch (indexPath.row) {
                case SPOptionsDebugRowStats: {
                    [self showDebugInformation];
                    break;
                }
            }
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
    [SPTracker trackUserSignedOut];
    [[SPAppDelegate sharedDelegate] logoutAndReset:sender];
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
    NSArray *switches       = @[ _condensedNoteListSwitch, _alphabeticalSortSwitch, _themeListSwitch, _biometrySwitch ];
    
    for (UISwitch *theSwitch in switches) {
        theSwitch.onTintColor   = [theme colorForKey:@"switchOnTintColor"];
        theSwitch.tintColor     = [theme colorForKey:@"switchTintColor"];
    }
    
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

@end
