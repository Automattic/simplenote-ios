#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class SPSidebarContainerViewController;
@class TagListViewController;
@class SPNoteListViewController;
@class SPNoteEditorViewController;
@class SPNavigationController;
@class VersionsController;
@class AccountVerificationController;
@class AccountVerificationViewController;
@class PublishController;
@class PublishStateObserver;
@class AccountDeletionController;
@class CoreDataManager;

NS_ASSUME_NONNULL_BEGIN

@interface SPAppDelegate : UIResponder <UIApplicationDelegate, SPBucketDelegate>

@property (nullable, strong, nonatomic) UIWindow                        *window;
@property (nullable, strong, nonatomic) UIWindow                        *pinLockWindow;

@property (strong, nonatomic) Simperium						            *simperium;
@property (strong, nonatomic) CoreDataManager                           *coreDataManager;

@property (strong, nonatomic) SPSidebarContainerViewController          *sidebarViewController;
@property (strong, nonatomic) TagListViewController                     *tagListViewController;
@property (strong, nonatomic) SPNoteListViewController                  *noteListViewController;
@property (strong, nonatomic) SPNavigationController                    *navigationController;

@property (strong, nonatomic) VersionsController                        *versionsController;
@property (strong, nonatomic) PublishController                         *publishController;

@property (weak, nonatomic) AccountVerificationViewController           *verificationViewController;
@property (strong, nonatomic, nullable) AccountVerificationController   *verificationController;

@property (nullable, strong, nonatomic) NSString                        *selectedTag;
@property (assign, nonatomic) BOOL										bSigningUserOut;

@property (nullable, strong, nonatomic) AccountDeletionController       *accountDeletionController;

- (void)connectWindow:(UIWindow *)window;
- (void)disconnectWindow;

- (void)didBecomeActive;
- (void)willResignActive;
- (void)willEnterForeground;
- (void)didEnterBackground;

- (void)handleURL:(NSURL *)url NS_SWIFT_NAME(handleURL(_:));
- (void)handleUserActivity:(NSUserActivity *)userActivity NS_SWIFT_NAME(handleUserActivity(_:));

- (void)presentSettingsViewController;

- (void)save;
- (void)logoutAndReset:(id)sender;
- (BOOL)isFirstLaunch;

+ (SPAppDelegate *)sharedDelegate;

@end

NS_ASSUME_NONNULL_END

