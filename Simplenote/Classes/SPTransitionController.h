#import <Foundation/Foundation.h>


extern NSString *const SPTransitionControllerPopGestureTriggeredNotificationName;

@interface SPTransitionController : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

- (instancetype)initWithTableView:(UITableView *)tableView
             navigationController:(UINavigationController *)navigationController;

@end
