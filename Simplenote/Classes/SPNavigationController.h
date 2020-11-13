#import <UIKit/UIKit.h>


typedef void(^SPNavigationControllerBlock)(void);

@interface SPNavigationController : UINavigationController

@property (nonatomic) BOOL displaysBlurEffect;
@property (nonatomic) BOOL disableRotation;
@property (nonatomic, copy) SPNavigationControllerBlock onWillDismiss;

@end
