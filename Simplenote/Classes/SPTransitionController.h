#import <Foundation/Foundation.h>


extern NSString *const SPTransitionControllerPopGestureTriggeredNotificationName;


@protocol SPInteractiveDismissableViewController
@property (readonly) BOOL requiresFirstResponderRestorationBypass;
@end


@interface SPTransitionController : NSObject <UINavigationControllerDelegate>
- (instancetype)initWithNavigationController:(UINavigationController *)navigationController;
@end
