//
//  SPAppDelegate.m
//  Simplenote
//
//  Created by Tom Witkin on 7/3/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPAppDelegate.h"
#import "Simplenote-Swift.h"

#import "SPConstants.h"

#import "SPNavigationController.h"
#import "SPLoginViewController.h"
#import "SPOnboardingViewController.h"
#import "SPNoteListViewController.h"
#import "SPNoteEditorViewController.h"
#import "SPOptionsViewController.h"
#import "SPTagsListViewController.h"

#import "NSManagedObjectContext+CoreDataExtensions.h"
#import "NSProcessInfo+Util.h"
#import "UIView+ImageRepresentation.h"
#import "SPModalActivityIndicator.h"
#import "SPEditorTextView.h"
#import "SPTransitionController.h"

#import "SPObjectManager.h"
#import "Note.h"
#import "Tag.h"
#import "Settings.h"
#import "SPIntegrityHelper.h"
#import "SPRatingsHelper.h"

#import "VSThemeManager.h"
#import "VSTheme.h"
#import "DTPinLockController.h"
#import "GAI.h"
#import "SPTracker.h"

@import SSKeychain;
@import Simperium;
@import WordPress_AppbotX;

#if USE_HOCKEY
#import <HockeySDK/HockeySDK.h>
#elif USE_CRASHLYTICS
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif


#pragma mark ================================================================================
#pragma mark Private Properties
#pragma mark ================================================================================

@interface SPAppDelegate () <UINavigationControllerDelegate,
#if USE_HOCKEY
                                BITHockeyManagerDelegate,
                                BITCrashManagerDelegate,
                                BITUpdateManagerDelegate,
#endif
                                SimperiumDelegate,
                                SPBucketDelegate,
                                PinLockDelegate>


@property (strong, nonatomic) Simperium						*simperium;
@property (strong, nonatomic) NSManagedObjectContext		*managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel			*managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator	*persistentStoreCoordinator;
@property (strong, nonatomic) UIWindow                      *welcomeWindow;
@property (weak,   nonatomic) SPModalActivityIndicator		*signOutActivityIndicator;

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
#pragma mark Legacy
#pragma mark ================================================================================

- (void)importLegacyAuthenticationData
{
    // First check for a legacy token and bring that over if possible (to avoid a sign in prompt)
    NSString *legacyAuthToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"spAuthToken"];
    NSString *username = (__bridge_transfer NSString *)CFPreferencesCopyAppValue(CFSTR("email"), kCFPreferencesCurrentApplication);
    
    if (legacyAuthToken && [username length] > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"SPUsername"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SSKeychain setPassword:legacyAuthToken forService:[SPCredentials simperiumAppID] account:username];
    }
    
    // Clear legacy data
    if (legacyAuthToken) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"spAuthToken"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (username) {
        CFPreferencesSetAppValue(CFSTR("email"), NULL, kCFPreferencesCurrentApplication);
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
    }
}
    
- (void)importLegacyPreferences
{
    NSNumber *legacySortPref = (__bridge_transfer NSNumber *)CFPreferencesCopyAppValue(CFSTR("sortMode"), kCFPreferencesCurrentApplication);
    if (legacySortPref != nil) {
        
        if ([legacySortPref integerValue] == 2) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SPAlphabeticalSortPref];
        }
        
        CFPreferencesSetAppValue(CFSTR("sortMode"), NULL, kCFPreferencesCurrentApplication);
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
    }
}


#pragma mark ================================================================================
#pragma mark Frameworks Setup
#pragma mark ================================================================================

- (void)setupSimperium
{
    [self importLegacyAuthenticationData];
    
	self.simperium = [[Simperium alloc] initWithModel:self.managedObjectModel
											  context:self.managedObjectContext
										  coordinator:self.persistentStoreCoordinator];
		  
#if USE_VERBOSE_LOGGING
    [_simperium setVerboseLoggingEnabled:YES];
    NSLog(@"verbose logging enabled");
#else
    [_simperium setVerboseLoggingEnabled:NO];
#endif
    
    _simperium.authenticationViewControllerClass    = [SPLoginViewController class];
    _simperium.authenticator.providerString         = @"simplenote.com";
	
    SPAuthenticationConfiguration *configuration    = [SPAuthenticationConfiguration sharedInstance];
    configuration.regularFontName                   = @"SourceSansPro-Regular";
    configuration.mediumFontName                    = @"SourceSansPro-Semibold";
    configuration.logoImageName                     = @"logo_login";
    configuration.forgotPasswordURL                 = kSimperiumForgotPasswordURL;
    configuration.termsOfServiceURL                 = kSimperiumTermsOfServiceURL;
    
    [_simperium setAllBucketDelegates:self];
    [_simperium setDelegate:self];
    
    NSArray *buckets = @[NSStringFromClass([Note class]),
                         NSStringFromClass([Tag class]),
                         NSStringFromClass([Settings class])];
    
    for (NSString *bucketName in buckets) {
        [_simperium bucketForName:bucketName].notifyWhileIndexing = YES;
    }
}

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
    
    self.window.backgroundColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"backgroundColor"];
    self.window.tintColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"tintColor"];
    
    // check to see if the app terminated with a previously selected tag
    NSString *selectedTag = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedTagKey];
    if (selectedTag != nil) {
		[self setSelectedTag:selectedTag];
	}
    
    _tagListViewController = [[SPTagsListViewController alloc] init];

    _noteListViewController = [[SPNoteListViewController alloc] initWithSidebarViewController:_tagListViewController];
    _noteListViewController.sidePanelViewDelegate = _tagListViewController;

    
    self.navigationController = [[SPNavigationController alloc] initWithRootViewController:_noteListViewController];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.delegate	= self;
    self.window.rootViewController		= self.navigationController;
    
    [self.window makeKeyAndVisible];
}

- (void)setupBitHockey
{
#if USE_HOCKEY
    NSLog(@"Initializing HockeyApp...");
    
    BITHockeyManager *hockeyManager = [BITHockeyManager sharedHockeyManager];
    NSString *identifier = [SPCredentials bitHockeyIdentifier];
    [hockeyManager configureWithIdentifier:identifier delegate:self];
    [hockeyManager startManager];

    BITAuthenticator *authenticator = hockeyManager.authenticator;
    [authenticator authenticateInstallation];
#endif
}

- (void)setupCrashlytics
{
#if USE_CRASHLYTICS
    NSLog(@"Initializing Crashlytics...");
    
    NSString *email = self.simperium.user.email;
    NSString *key = [SPCredentials simplenoteCrashlyticsKey];

    [Fabric with:@[CrashlyticsKit]];

    [Crashlytics startWithAPIKey:key];
    [[Crashlytics sharedInstance] setObjectValue:email forKey:@"email"];

#endif
}

- (void)setupGoogleAnalytics
{
    [[GAI sharedInstance] trackerWithTrackingId:[SPCredentials googleAnalyticsID]];
}

- (void)setupThemeNotifications
{
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(themeDidChange) name:VSThemeManagerThemeDidChangeNotification object:nil];
    [nc addObserver:self selector:@selector(themeWillChange) name:VSThemeManagerThemeWillChangeNotification object:nil];
}


#pragma mark ================================================================================
#pragma mark AppDelegate Methods
#pragma mark ================================================================================

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Old School!
    [self importLegacyPreferences];

	// Setup Frameworks
    [self setupThemeNotifications];
    [self setupSimperium];
	[self setupBitHockey];
    [self setupCrashlytics];
	[self setupGoogleAnalytics];
    [self setupDefaultWindow];
    [self setupAppRatings];
    
	// Once the UI is wired, Auth Simperium
	[self authenticateSimperium];
    
    // Initialize UI
    [self loadLastSelectedNote];
    [self loadSelectedTheme];
    
    // Check to see if first time user
    if ([self isFirstLaunch]) {        
        [self showOnboardingScreen];
        [self createWelcomeNoteAfterDelay];
        [self markFirstLaunch];
    } else {
        [self showPasscodeLockIfNecessary];
    }

    
//    // Initialize Background Fetch:
//    // UIApplicationBackgroundFetchIntervalMinimum enables the device to check as frequently as it sees fit
//	[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
	
    // Integrity Check: Fallback to GhostData, if needed
    [SPIntegrityHelper reloadInconsistentNotesIfNeeded:self.simperium];
    
    return YES;
}

- (void)onboardingDidFinish:(NSNotification *)notification
{
    [self.window makeKeyAndVisible];
    self.welcomeWindow = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self showPasscodeLockIfNecessary];
    UIViewController *viewController = self.window.rootViewController;
    [viewController.view setNeedsLayout];
    
    // Save any pending changes
    [self.noteEditorViewController save];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Save the current note and tag
    if (_selectedTag) {
        [[NSUserDefaults standardUserDefaults] setObject:_selectedTag forKey:kSelectedTagKey];
    }
    
    NSString *currentNoteKey = self.noteEditorViewController.currentNote.simperiumKey;
    if (currentNoteKey) {
        [[NSUserDefaults standardUserDefaults] setObject:currentNoteKey forKey:kSelectedNoteKey];
    }
    
    // Save any pending changes
    [self.noteEditorViewController save];
}


#pragma mark Background Fetch

//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    NSLog(@">> Simplenote performing Background Fetch");
//    
//    [self.simperium backgroundFetchWithCompletion:^(UIBackgroundFetchResult result) {
//        
//        if (result == UIBackgroundFetchResultNewData) {
//            NSLog(@"<< Background Fetch: New Data Received");
//        } else if (result == UIBackgroundFetchResultNoData) {
//            NSLog(@"<< Background Fetch: No Data Received");
//        }
//
//        completionHandler(result);
//    }];
//}


#pragma mark First Launch

- (BOOL)isFirstLaunch
{
    NSNumber *firstLaunchKey = [[NSUserDefaults standardUserDefaults] objectForKey:kFirstLaunchKey];
    BOOL firstLaunch = firstLaunchKey == nil;
    if (firstLaunch) {
        NSNumber *legacyFirstLaunch = (__bridge_transfer NSNumber *)CFPreferencesCopyAppValue(CFSTR("first-startup"),
                                                                                              kCFPreferencesCurrentApplication);
        
        if (legacyFirstLaunch && legacyFirstLaunch.boolValue == false) {
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:kFirstLaunchKey];
            firstLaunch = NO;
        }
    }
    
    return firstLaunch;
}

- (void)createWelcomeNoteAfterDelay
{
    [self performSelector:@selector(createWelcomeNote) withObject:nil afterDelay:0.5];
}

- (void)createWelcomeNote
{
    NSString *welcomeKey = @"welcomeNote-iOS";
    SPBucket *noteBucket = [_simperium bucketForName:@"Note"];
    Note *welcomeNote = [noteBucket objectForKey:welcomeKey];
    
    if (welcomeNote) {
        return;
	}
    
    welcomeNote = [noteBucket insertNewObjectForKey:welcomeKey];
    welcomeNote.modificationDate = [NSDate date];
    welcomeNote.creationDate = [NSDate date];
    welcomeNote.content = NSLocalizedString(@"welcomeNote-iOS", @"A welcome note for new iOS users");
    [self save];
    
    _noteListViewController.firstLaunch = YES;
}

- (void)showOnboardingScreen
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onboardingDidFinish:) name:SPOnboardingDidFinish object:nil];
    self.welcomeWindow = [[UIWindow alloc] initWithFrame:self.window.frame];
    self.welcomeWindow.backgroundColor = [UIColor clearColor];
    self.welcomeWindow.rootViewController = [SPOnboardingViewController new];
    [self.welcomeWindow makeKeyAndVisible];
    
    // Remove any stored pin code
    [self removePin];
}

- (void)markFirstLaunch
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(1) forKey:kFirstLaunchKey];
    [userDefaults synchronize];
}


#pragma mark - Launch Helpers

- (void)loadLastSelectedNote
{
    NSString *selectedNoteKey = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedNoteKey];
    if (selectedNoteKey) {
        Note *selectedNote = [_noteListViewController noteForKey:selectedNoteKey];
        if (selectedNote) {
            [_noteListViewController openNote:selectedNote fromIndexPath:nil animated:NO];
        }
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSelectedNoteKey];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSelectedTagKey];
}

- (void)loadSelectedTheme
{
    [[VSThemeManager sharedManager] applyAppearanceStylingForTheme:[[VSThemeManager sharedManager] theme]];
}


#pragma mark ================================================================================
#pragma mark Theme's
#pragma mark ================================================================================

- (void)themeWillChange
{
    // Save current note if editing
    if (_noteEditorViewController.currentNote) {
        [_noteEditorViewController save];
        [_noteEditorViewController.noteEditorTextView endEditing:YES];
    }
}

- (void)themeDidChange
{
    // Update window coloring
    self.window.backgroundColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"backgroundColor"];
    self.window.tintColor = [[[VSThemeManager sharedManager] theme] colorForKey:@"tintColor"];
}


#pragma mark ================================================================================
#pragma mark Core Data stack
#pragma mark ================================================================================

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setUndoManager:nil];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]  pathForResource:@"Simplenote" ofType:@"momd"]];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Simplenote.sqlite"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"Simplenote.sqlite"];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Perform automatic, lightweight migration
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}


#pragma mark ================================================================================
#pragma mark Other
#pragma mark ================================================================================

- (void)dismissAllModalsAnimated:(BOOL)animated completion:(void(^)())completion
{
    [self.navigationController dismissViewControllerAnimated:animated
                                                  completion:^{
                                                      
                                                      if (completion) {
                                                          completion();
                                                      }
                                                  }];
    
}

- (void)showOptions
{
    SPOptionsViewController *optionsViewController = [[SPOptionsViewController alloc] init];
	
    SPNavigationController *navController	= [[SPNavigationController alloc] initWithRootViewController:optionsViewController];
    navController.disableRotation			= self.navigationController.disableRotation;
    navController.modalPresentationStyle	= UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
}

- (void)logoutAndReset:(id)sender
{
    self.bSigningUserOut = YES;
    self.signOutActivityIndicator = [SPModalActivityIndicator show];
    
    double delayInSeconds = 0.75;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [_simperium signOutAndRemoveLocalData:YES completion:^{
			        
			[_noteEditorViewController clearNote];
			_selectedTag = nil;
			[_noteListViewController update];
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults removeObjectForKey:kSelectedNoteKey];
			[defaults removeObjectForKey:kSelectedTagKey];
            [defaults removeObjectForKey:kSimplenoteMarkdownDefaultKey];
			[defaults synchronize];
			
            // Always fall back to the default theme
            [[VSThemeManager sharedManager] swapTheme:kSimplenoteDefaultThemeName];
            
			// remove the pin lock
			[self removePin];
			
			// hide sidebar of notelist
			[[self noteListViewController] hideSidePanelAnimated:NO completion:nil];
			
			[self dismissAllModalsAnimated:YES completion:^{
				
				[_simperium authenticateIfNecessary];
				_bSigningUserOut = NO;
			}];
		}];
    });
}

- (void)save
{
    [self.simperium save];
}


#pragma mark ================================================================================
#pragma mark Simperium delegate
#pragma mark ================================================================================

- (void)simperiumDidLogin:(Simperium *)simperium
{
    // Store the Token: Required by the Share Extension!
    NSString *token = simperium.user.authToken;
    [SSKeychain setPassword:token forService:kShareExtensionServiceName account:kShareExtensionAccountName];
    
    // Tracker!
    [SPTracker refreshMetadataWithEmail:simperium.user.email];
}

- (void)simperiumDidLogout:(Simperium *)simperium
{
    // Nuke Extension Token
    [SSKeychain deletePasswordForService:kShareExtensionServiceName account:kShareExtensionAccountName];
    
    // Tracker!
    [SPTracker refreshMetadataForAnonymousUser];
}

- (void)simperium:(Simperium *)simperium didFailWithError:(NSError *)error
{
    [SPTracker refreshMetadataForAnonymousUser];
}

#pragma mark ================================================================================
#pragma mark SPBucket delegate
#pragma mark ================================================================================

- (void)bucket:(SPBucket *)bucket didChangeObjectForKey:(NSString *)key forChangeType:(SPBucketChangeType)change memberNames:(NSArray *)memberNames
{
    if ([bucket.name isEqualToString:NSStringFromClass([Note class])]) {
        // Note change
        switch (change) {
            case SPBucketChangeUpdate:
                if ([key isEqualToString:_noteEditorViewController.currentNote.simperiumKey]) {
                    [_noteEditorViewController didReceiveNewContent];
                }
                break;
            case SPBucketChangeInsert:
                break;
			case SPBucketChangeDelete:
                if ([key isEqualToString:_noteEditorViewController.currentNote.simperiumKey]) {
					[_noteEditorViewController didDeleteCurrentNote];
				}
				break;
            default:
                break;
        }
    } else if ([bucket.name isEqualToString:NSStringFromClass([Tag class])]) {
        // Tag deleted
        switch (change) {
            case SPBucketChangeDelete: {
                // if selected tag is deleted, swap the note list view controller
                if ([key isEqual:self.selectedTag]) {
                    self.selectedTag = nil;
                    [self.noteListViewController update];
                }
                break;
            }
            default:
                break;
        }
    } else if ([bucket.name isEqualToString:NSStringFromClass([Settings class])]) {
        [[SPRatingsHelper sharedInstance] reloadSettings];
    }
}

- (void)bucket:(SPBucket *)bucket willChangeObjectsForKeys:(NSSet *)keys
{
    if ([bucket.name isEqualToString:@"Note"]) {
        for (NSString *key in keys) {
            if ([key isEqualToString: _noteEditorViewController.currentNote.simperiumKey]) {
                [_noteEditorViewController willReceiveNewContent];
			}
        }
    }
}

- (void)bucket:(SPBucket *)bucket didReceiveObjectForKey:(NSString *)key version:(NSString *)version data:(NSDictionary *)data
{
    if ([bucket.name isEqualToString:@"Note"]) {
        if ([key isEqualToString:_noteEditorViewController.currentNote.simperiumKey]) {
            [_noteEditorViewController didReceiveVersion:version data:data];
		}
    }
}

- (void)bucketWillStartIndexing:(SPBucket *)bucket
{
    if ([bucket.name isEqualToString:@"Note"]) {
        [_noteListViewController setWaitingForIndex:YES];
    }
}

- (void)bucketDidFinishIndexing:(SPBucket *)bucket
{
    if ([bucket.name isEqualToString:@"Note"]) {
        [_noteListViewController setWaitingForIndex:NO];
    }
}


#pragma mark ================================================================================
#pragma mark URL scheme
#pragma mark ================================================================================

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{    
    // Support opening Simplenote and optionally creating a new note
    if ([[url host] isEqualToString:@"new"]) {
        
        Note *newNote = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
                                                              inManagedObjectContext:self.managedObjectContext];
        newNote.creationDate = [NSDate date];
        newNote.modificationDate = [NSDate date];
        
        NSArray *params = [[url query] componentsSeparatedByString:@"&"];
        for (NSString *param in params) {
            NSArray *paramArray = [param componentsSeparatedByString:@"="];
            if ([paramArray count] < 2) {
                continue;
            }
            
            NSString *key = [paramArray objectAtIndex:0];
            NSString *value = [[paramArray objectAtIndex:1] stringByRemovingPercentEncoding];
            
            if ([key isEqualToString:@"content"]) {
                newNote.content = value;
            } else if ([key isEqualToString:@"tag"]) {
                NSArray *tags = [value componentsSeparatedByString:@" "];
                for (NSString *tag in tags) {
                    if (tag.length == 0)
                        continue;
                    [newNote addTag:tag];
                    [[SPObjectManager sharedManager] createTagFromString:tag];
                }
            }
        }
        [_simperium save];
        
        // Hide any modals
        [self dismissAllModalsAnimated:NO completion:nil];
        
        // If root tag list is currently being viewed, push All Notes instead
        [self.noteListViewController hideSidePanelAnimated:NO completion:nil];
        
        // On iPhone, make sure a note isn't currently being edited
        if (self.navigationController.visibleViewController == _noteEditorViewController) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        
        // Little trick to postpone until next run loop to ensure controllers have a chance to pop
        double delayInSeconds = 0.05;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_noteListViewController openNote:newNote fromIndexPath:nil animated:NO];
            [self showPasscodeLockIfNecessary];
        });
    }
    
    return true;
}



#pragma mark ================================================================================
#pragma mark Passcode Lock
#pragma mark ================================================================================

- (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

-(void)showPasscodeLockIfNecessary
{
    
    NSString *pin = [self getPin:YES];
    
    if (!pin || pin.length == 0 || [[self topMostController] class] == [DTPinLockController class]) {
        return;
	}
    
    BOOL useTouchID = self.allowTouchIDInsteadOfPin;
    DTPinLockController *controller = [[DTPinLockController alloc] initWithMode:useTouchID ? PinLockControllerModeUnlockAllowTouchID :PinLockControllerModeUnlock];
	controller.pinLockDelegate = self;
	controller.pin = pin;
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	
	// no animation to cover up app right away
	[[self topMostController] presentViewController:controller animated:NO completion:nil];
	[controller fixLayout];
}

- (void)pinLockControllerDidFinishUnlocking
{
	[[self topMostController] dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getPin:(BOOL)checkLegacy
{
    NSString *pin   = [SSKeychain passwordForService:kSimplenotePinKey account:kSimplenotePinKey];
    
    if (checkLegacy && (!pin || pin.length == 0)) {
        
        pin =  [[NSUserDefaults standardUserDefaults] objectForKey:kSimplenotePinLegacyKey];
        
        if (pin.length > 0) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSimplenotePinLegacyKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setPin:pin];
        }
    }
    
    return pin;
}

- (void)setPin:(NSString *)newPin
{
    [SSKeychain setPassword:newPin forService:kSimplenotePinKey account:kSimplenotePinKey];
}

- (void)removePin
{
    [SSKeychain deletePasswordForService:kSimplenotePinKey account:kSimplenotePinKey];
}

- (BOOL)allowTouchIDInsteadOfPin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL useTouchID = [userDefaults boolForKey:kSimplenoteUseTouchIDKey];

    return useTouchID;
}

- (void)setAllowTouchIDInsteadOfPin:(BOOL)allowTouchIDInsteadOfPin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:allowTouchIDInsteadOfPin forKey:kSimplenoteUseTouchIDKey];
    [userDefaults synchronize];
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
    
    // Initialize AppbotX
    [[ABXApiClient instance] setApiKey:[SPCredentials appbotKey]];
    
    // Initialize AppRatings Helper
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
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
