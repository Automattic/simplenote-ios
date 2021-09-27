#import <UIKit/UIKit.h>

@interface SPModalActivityIndicator : UIView {
    
    CGRect boxFrame;
    UIView *topView;
}

@property (nonatomic, retain) UIView *contentView;

+ (SPModalActivityIndicator *)showInWindow:(UIWindow *)window;
- (void)dismiss:(BOOL)animated completion:(void (^)())completion;

@end
