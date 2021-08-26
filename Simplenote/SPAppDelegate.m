#import "SPAppDelegate.h"
#import "Simplenote-Swift.h"

#import "SPConstants.h"

#import "SPNavigationController.h"
#import "SPNoteListViewController.h"
#import "SPNoteEditorViewController.h"
#import "SPSettingsViewController.h"
#import "SPAddCollaboratorsViewController.h"

#import "NSManagedObjectContext+CoreDataExtensions.h"
#import "NSProcessInfo+Util.h"
#import "SPModalActivityIndicator.h"
#import "SPEditorTextView.h"

#import "SPObjectManager.h"
#import "Note.h"
#import "Tag.h"
#import "Settings.h"
#import "SPRatingsHelper.h"
#import "WPAuthHandler.h"

#import "SPTracker.h"

@import Contacts;
@import Simperium;

@class KeychainMigrator;

#if USE_APPCENTER
@import AppCenter;
@import AppCenterDistribute;
#endif


#pragma mark ================================================================================
#pragma mark Private Properties
#pragma mark ================================================================================

@interface SPAppDelegate ()

@property (weak,   nonatomic) SPModalActivityIndicator      *signOutActivityIndicator;

@end


#pragma mark ================================================================================
#pragma mark Simplenote AppDelegate
#pragma mark ================================================================================

@implementation SPAppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark ================================================================================
#pragma mark Frameworks Setup
#pragma mark ================================================================================

- (void)authenticateSimperium
{
	NSAssert(self.navigationController, nil);
	[_simperium authenticateWithAppID:[SPCredentials simperiumAppID] APIKey:[SPCredentials simperiumApiKey] rootViewController:self.navigationController];
}

- (void)setupDefaultWindow
{
    if (!self.window) {
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    self.window.backgroundColor = [UIColor simplenoteWindowBackgroundColor];
    self.window.tintColor = [UIColor simplenoteTintColor];

    self.tagListViewController = [TagListViewController new];
    self.noteListViewController = [SPNoteListViewController new];

    self.navigationController = [[SPNavigationController alloc] initWithRootViewController:_noteListViewController];

    self.sidebarViewController = [[SPSidebarContainerViewController alloc] initWithMainViewController:self.navigationController
                                                                                sidebarViewController:self.tagListViewController];
    self.sidebarViewController.delegate = self.noteListViewController;

    self.window.rootViewController = self.sidebarViewController;
    
    [self.window makeKeyAndVisible];
}

- (void)setupAppCenter
{
#if USE_APPCENTER
    NSLog(@"Initializing AppCenter...");
    
    NSString *identifier = [SPCredentials appCenterIdentifier];
    [MSAppCenter start:identifier withServices:@[[MSDistribute class]]];
    [MSDistribute setEnabled:true];
#endif
}

- (void)setupCrashLogging
{
    [CrashLogging startWithSimperium: self.simperium];
}

- (void)setupThemeNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(themeDidChange) name:SPSimplenoteThemeChangedNotification object:nil];
}

#pragma mark ================================================================================
#pragma mark AppDelegate Methods
#pragma mark ================================================================================

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions
{
    // Setup Frameworks
    [self setupStorage];
    [self setupThemeNotifications];
    [self setupSimperium];
    [self setupAuthenticator];
    [self setupAppCenter];
    [self setupCrashLogging];
    [self configureVersionsController];
    [self configurePublishController];
    [self configureAccountDeletionController];
    [self setupDefaultWindow];
    [self configureStateRestoration];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Once the UI is wired, Auth Simperium
	[self authenticateSimperium];

    // Handle Simplenote Migrations: We *need* to initialize the Ratings framework after this step, for reasons be.
    [[MigrationsHandler new] ensureUpdateIsHandled];
    [self setupAppRatings];

    [[ShortcutsHandler shared] updateHomeScreenQuickActionsIfNeeded];

    // Initialize UI
    [self loadSelectedTheme];
    
    // Check to see if first time user
    if ([self isFirstLaunch]) {
        _noteListViewController.firstLaunch = YES;
        [[SPPinLockManager shared] removePin];
        [self markFirstLaunch];
    } else {
        [self showPasscodeLockIfNecessary];
    }

    // Index (All of the) Spotlight Items if the user upgraded
    [self indexSpotlightItemsIfNeeded];

    [self setupNoticeController];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [SPTracker trackApplicationOpened];
    [self syncWidgetDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [SPTracker trackApplicationClosed];

    // For the passcode lock, store the current clock time for comparison when returning to the app
    if ([self.window isKeyWindow]) {
        [[SPPinLockManager shared] storeLastUsedTime];
    }

    [self showPasscodeLockIfNecessary];
    [self cleanupScrollPositionCache];
    [self syncWidgetDefaults];
    [self resetWidgetTimelines];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self dismissPasscodeLockIfPossible];
    [self authenticateSimperiumIfAccountDeletionRequested];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    return [[ShortcutsHandler shared] handleUserActivity:userActivity];
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [[ShortcutsHandler shared] handleApplicationShortcut:shortcutItem];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    UIViewController *viewController = self.window.rootViewController;
    [viewController.view setNeedsLayout];
    
    // Save any pending changes
    [self.noteEditorViewController save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Save any pending changes
    [self.noteEditorViewController save];
}

// Deprecated in iOS 13.2. Per the docs, this method will not be called in favor of the new secure version when both are defined.
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveSecureApplicationState:(NSCoder *)coder
{
    return YES;
}

// Deprecated in iOS 13.2. Per the docs, this method will not be called in favor of the new secure version when both are defined.
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreSecureApplicationState:(NSCoder *)coder
{
    return YES;
}


#pragma mark - First Launch

- (BOOL)isFirstLaunch
{
    return [[Options shared] firstLaunch] == NO;
}

- (void)markFirstLaunch
{
    [[Options shared] setFirstLaunch:YES];
}


#pragma mark - Launch Helpers

- (void)loadSelectedTheme
{
    [[SPUserInterface shared] refreshUserInterfaceStyle];
}


#pragma mark - Theme's

- (void)themeDidChange
{
    self.window.backgroundColor = [UIColor simplenoteBackgroundColor];
    self.window.tintColor = [UIColor simplenoteTintColor];
}

#pragma mark ================================================================================
#pragma mark Other
#pragma mark ================================================================================

- (void)presentSettingsViewController
{
    SPSettingsViewController *settingsViewController = [SPSettingsViewController new];
	
    SPNavigationController *navController = [[SPNavigationController alloc] initWithRootViewController:settingsViewController];
    navController.disableRotation = YES;
    navController.displaysBlurEffect = YES;
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalPresentationCapturesStatusBarAppearance = YES;
    
    [self.sidebarViewController presentViewController:navController animated:YES completion:nil];
}

- (void)logoutAndReset:(id)sender
{
    self.bSigningUserOut = YES;

    [self dismissAllModalsAnimated:YES completion:nil];
    self.signOutActivityIndicator = [SPModalActivityIndicator show];
    
    // Reset State
    [SPKeychain deletePasswordForService:kSimplenoteWPServiceName account:self.simperium.user.email];
    [[ShortcutsHandler shared] unregisterSimplenoteActivities];
    [self.accountDeletionController clearRequestToken];

    // Actual Simperium Logout
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self.simperium signOutAndRemoveLocalData:YES completion:^{

            [self.navigationController popToRootViewControllerAnimated:YES];
            self.selectedTag = nil;
            [self.noteListViewController update];
			
            [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:nil];
            
            // Nuke all of the User Preferences
            [[Options shared] reset];
            
			// remove the pin lock
            [[SPPinLockManager shared] removePin];
			
			// hide sidebar of notelist
            [self.sidebarViewController hideSidebarWithAnimation:NO];
            [self.signOutActivityIndicator dismiss:YES completion:nil];

            [self.simperium authenticateIfNecessary];
            self.bSigningUserOut = NO;
        }];
    });
}

- (void)save
{
    [self.simperium save];
}

- (void)setSelectedTag:(NSString *)selectedTag {
    BOOL tagsEqual = _selectedTag == selectedTag || (_selectedTag != nil && selectedTag != nil && [_selectedTag isEqual:selectedTag]);
    if (tagsEqual) {
        return;
    }

    _selectedTag = selectedTag;
    [_noteListViewController update];
}

#pragma mark ================================================================================
#pragma mark SPBucket delegate
#pragma mark ================================================================================

- (void)bucket:(SPBucket *)bucket didChangeObjectForKey:(NSString *)key forChangeType:(SPBucketChangeType)change memberNames:(NSArray *)memberNames
{
    if ([bucket isEqual:[_simperium notesBucket]]) {
        // Note change
        switch (change) {
            case SPBucketChangeTypeUpdate:
            {
                if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                    [self.noteEditorViewController didReceiveNewContent];
                }

                [self.publishController didReceiveUpdateNotificationForKey:key withMemberNames:memberNames];


                Note *note = [bucket objectForKey:key];
                if (note && !note.deleted) {
                    [[CSSearchableIndex defaultSearchableIndex] indexSearchableNote:note];
                } else {
                    [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[key] completionHandler:nil];
                }
            }
                break;
            case SPBucketChangeTypeInsert:
                break;
			case SPBucketChangeTypeDelete:
            {
                if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                    [self.noteEditorViewController didDeleteCurrentNote];
                }

                [self.publishController didReceiveDeleteNotificationsForKey:key];


                [[CSSearchableIndex defaultSearchableIndex] deleteSearchableItemsWithIdentifiers:@[key] completionHandler:nil];
            }
				break;
            default:
                break;
        }
    } else if ([bucket isEqual:[_simperium tagsBucket]]) {
        // Tag deleted
        switch (change) {
            case SPBucketChangeTypeDelete:
            {
                // if selected tag is deleted, swap the note list view controller
                if ([key isEqual:self.selectedTag]) {
                    self.selectedTag = nil;
                }
                break;
            }
            default:
                break;
        }
    } else if ([bucket isEqual:[_simperium settingsBucket]]) {
        [[SPRatingsHelper sharedInstance] reloadSettings];
    } else if ([bucket isEqual:[_simperium accountBucket]] && [key isEqualToString:SPCredentials.simperiumEmailVerificationObjectKey]) {
        [_verificationController updateWith:[bucket objectForKey:key]];
    }
}

- (void)bucket:(SPBucket *)bucket willChangeObjectsForKeys:(NSSet *)keys
{
    if ([bucket isEqual:[_simperium notesBucket]]) {
        for (NSString *key in keys) {
            if ([key isEqualToString:self.noteEditorViewController.note.simperiumKey]) {
                [self.noteEditorViewController willReceiveNewContent];
            }
        }
    }
}

- (void)bucket:(SPBucket *)bucket didReceiveObjectForKey:(NSString *)key version:(NSString *)version data:(NSDictionary *)data
{
    if ([bucket isEqual:[_simperium notesBucket]]) {
        [self.versionsController didReceiveObjectForSimperiumKey:key version:[version integerValue] data:data];
    }
}

- (void)bucketWillStartIndexing:(SPBucket *)bucket
{
    if ([bucket isEqual:[_simperium notesBucket]]) {
        [_noteListViewController setWaitingForIndex:YES];
    }
}

- (void)bucketDidFinishIndexing:(SPBucket *)bucket
{
    if ([bucket isEqual:[_simperium notesBucket]]) {
        [_noteListViewController setWaitingForIndex:NO];
        [self indexSpotlightItems];
    } else if ([bucket isEqual:[_simperium accountBucket]]) {
        [_verificationController updateWith:[bucket objectForKey:SPCredentials.simperiumEmailVerificationObjectKey]];
    }
}


#pragma mark ================================================================================
#pragma mark Spotlight
#pragma mark ================================================================================

- (void)indexSpotlightItemsIfNeeded
{
    // This process should be executed *just once*, and only if the user is already logged in (AKA "Upgrade")
    NSString *kSpotlightDidRunKey = @"SpotlightDidRunKey";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults boolForKey:kSpotlightDidRunKey] == true) {
        return;
    }

    [defaults setBool:true forKey:kSpotlightDidRunKey];
    [defaults synchronize];

    if (self.simperium.user.authenticated == false) {
        return;
    }

    [self indexSpotlightItems];
}

- (void)indexSpotlightItems
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:self.simperium.managedObjectContext];
    
    [context performBlock:^{
        NSArray *deleted = [context fetchObjectsForEntityName:@"Note" withPredicate:[NSPredicate predicateWithFormat:@"deleted == YES"]];
        [[CSSearchableIndex defaultSearchableIndex] deleteSearchableNotes:deleted];
        
        NSArray *notes = [context fetchObjectsForEntityName:@"Note" withPredicate:[NSPredicate predicateWithFormat:@"deleted == NO"]];
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableNotes:notes];
    }];
}


#pragma mark ================================================================================
#pragma mark URL scheme
#pragma mark ================================================================================

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if (!self.simperium.user.authenticated) {
        [self performDotcomAuthenticationWithURL:url];

        if (!self.simperium.user.authenticated && url) {
            [self performMagicLinkAuthenticationWith:url];
        }
        return YES;
    }

    // URL: Open a Note!
    if ([self handleOpenNoteWithUrl:url]) {
        return YES;
    }

    // Support opening Simplenote and optionally creating a new note
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    if ([[components host] isEqualToString:@"new"]) {
        
        Note *newNote = [[SPObjectManager sharedManager] newNoteFrom:components];

        [self presentNote:newNote animated:NO];
    }
    
    return YES;
}

- (void)performDotcomAuthenticationWithURL:(NSURL *)url
{
    if (![WPAuthHandler isWPAuthenticationUrl:url]) {
        return;
    }

    SPUser *user = [WPAuthHandler authorizeSimplenoteUserFromUrl:url forAppId:[SPCredentials simperiumAppID]];
    if (user == nil) {
        return;
    }

    self.simperium.user = user;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self.simperium authenticationDidSucceedForUsername:user.email token:user.authToken];

    [SPTracker trackWPCCLoginSucceeded];
}

#pragma mark ================================================================================
#pragma mark App Tracking
#pragma mark ================================================================================

- (void)setupAppRatings
{
    // Dont start App Tracking if we are running the test suite
    if ([NSProcessInfo isRunningTests]) {
        return;
    }

    NSString *version = [[NSBundle mainBundle] shortVersionString];
    
    [[SPRatingsHelper sharedInstance] initializeForVersion:version];
    [[SPRatingsHelper sharedInstance] reloadSettings];
}


#pragma mark ================================================================================
#pragma mark Static Helpers
#pragma mark ================================================================================

+ (SPAppDelegate *)sharedDelegate
{
    return (SPAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
