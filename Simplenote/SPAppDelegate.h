#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class SPSidebarContainerViewController;
@class TagListViewController;
@class SPNoteListViewController;
@class SPNoteEditorViewController;
@class SPNavigationController;
@class VersionsController;

NS_ASSUME_NONNULL_BEGIN

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nullable, strong, nonatomic) UIWindow *pinLockWindow;

@property (strong, nonatomic, readonly) Simperium						*simperium;
@property (strong, nonatomic, readonly) NSManagedObjectContext			*managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel			*managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

@property (strong, nonatomic) SPSidebarContainerViewController          *sidebarViewController;
@property (strong, nonatomic) TagListViewController                     *tagListViewController;
@property (strong, nonatomic) SPNoteListViewController                  *noteListViewController;
@property (strong, nonatomic) SPNavigationController                    *navigationController;

@property (strong, nonatomic) VersionsController                        *versionsController;

@property (nullable, strong, nonatomic) NSString                        *selectedTag;
@property (assign, nonatomic) BOOL										bSigningUserOut;

@property (assign, nonatomic) BOOL                                      allowBiometryInsteadOfPin;

- (void)presentSettingsViewController;

- (void)save;
- (void)logoutAndReset:(id)sender;

- (void)presentNewNoteEditor;
- (void)presentNoteWithUniqueIdentifier:(nullable NSString *)uuid;

+ (SPAppDelegate *)sharedDelegate;

@end

NS_ASSUME_NONNULL_END

