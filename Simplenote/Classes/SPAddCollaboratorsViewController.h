#import <UIKit/UIKit.h>
#import "SPEntryListViewController.h"


NS_ASSUME_NONNULL_BEGIN

@class SPAddCollaboratorsViewController;
@protocol SPCollaboratorDelegate <NSObject>

@required

- (BOOL)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
               shouldAddCollaborator:(NSString *)collaboratorEmail;
- (void)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
                  didAddCollaborator:(NSString *)collaboratorEmail;
- (void)collaboratorViewController:(SPAddCollaboratorsViewController *)viewController
                  didRemoveCollaborator:(NSString *)collaboratorEmail;

@end

@interface SPAddCollaboratorsViewController : SPEntryListViewController

@property (nonatomic, nullable, weak) id<SPCollaboratorDelegate> collaboratorDelegate;

- (void)setupWithCollaborators:(NSArray<NSString *> *)collaborators;

@end

NS_ASSUME_NONNULL_END
