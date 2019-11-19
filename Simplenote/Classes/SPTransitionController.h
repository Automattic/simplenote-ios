#import <Foundation/Foundation.h>


extern NSString *const SPTransitionControllerPopGestureTriggeredNotificationName;

@protocol SPTransitionControllerDelegate <NSObject>
- (void)interactionBegan;
@end

@interface SPTransitionController : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) id <SPTransitionControllerDelegate> delegate;
@property (nonatomic) BOOL transitioning;
@property (nonatomic) BOOL hasActiveInteraction;
@property (nonatomic) UINavigationControllerOperation navigationOperation;
@property (nonatomic) UITableView *tableView;

@property (nonatomic) NSIndexPath *selectedPath;

- (instancetype)initWithTableView:(UITableView *)tableView
             navigationController:(UINavigationController *)navigationController;

@end
