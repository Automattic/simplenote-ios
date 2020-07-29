#import <UIKit/UIKit.h>
#import <Simperium/Simperium.h>


@class SPSidebarContainerViewController;
@class SPTagsListViewController;
@class SPNoteListViewController;
@class SPNoteEditorViewController;
@class SPNavigationController;

NS_ASSUME_NONNULL_BEGIN

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nullable, strong, nonatomic) UIWindow *pinLockWindow;

@property (strong, nonatomic, readonly) Simperium						*simperium;
@property (strong, nonatomic, readonly) NSManagedObjectContext			*managedObjectContext;
@property (strong, nonatomic, readonly) NSManagedObjectModel			*managedObjectModel;
@property (strong, nonatomic, readonly) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

@property (strong, nonatomic) SPSidebarContainerViewController          *sidebarViewController;
@property (strong, nonatomic) SPTagsListViewController                  *tagListViewController;
@property (strong, nonatomic) SPNoteListViewController                  *noteListViewController;
@property (strong, nonatomic) SPNoteEditorViewController                *noteEditorViewController;
@property (strong, nonatomic) SPNavigationController                    *navigationController;

@property (nullable, strong, nonatomic) NSString                        *selectedTag;
@property (assign, nonatomic) BOOL										bSigningUserOut;

@property (assign, nonatomic) BOOL                                      allowBiometryInsteadOfPin;

- (void)showOptions;

- (void)save;
- (void)logoutAndReset:(id)sender;

- (NSString *)getPin:(BOOL)checkLegacy;
- (void)setPin:(NSString *)newPin;
- (void)removePin;

- (void)presentNewNoteEditor;
- (void)presentNoteWithUniqueIdentifier:(nullable NSString *)uuid;

+ (SPAppDelegate *)sharedDelegate;

@end

NS_ASSUME_NONNULL_END

