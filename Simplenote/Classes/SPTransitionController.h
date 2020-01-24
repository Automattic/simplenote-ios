#import <Foundation/Foundation.h>


extern NSString *const SPTransitionControllerPopGestureTriggeredNotificationName;

@interface SPTransitionController : NSObject <UINavigationControllerDelegate>

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;

@end
