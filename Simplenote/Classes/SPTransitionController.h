#import <Foundation/Foundation.h>


extern NSString *const SPTransitionControllerPopGestureTriggeredNotificationName;


@interface SPTransitionController : NSObject <UINavigationControllerDelegate>

@property (nonatomic) BOOL transitioning;
@property (nonatomic) BOOL hasActiveInteraction;
@property (nonatomic) UINavigationControllerOperation navigationOperation;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSIndexPath *selectedPath;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
