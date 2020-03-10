#import <UIKit/UIKit.h>

@interface SPModalActivityIndicator : UIView {
    
    CGRect boxFrame;

    UIView *parentView;
    UIView *topView;
}

@property (nonatomic, retain) UIView *contentView;

+ (SPModalActivityIndicator *)show;
- (void)dismiss:(BOOL)animated completion:(void (^)())completion;

@end
