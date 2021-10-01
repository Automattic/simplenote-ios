#import "SPModalActivityIndicator.h"
#import "Simplenote-Swift.h"


@implementation SPModalActivityIndicator

+ (SPModalActivityIndicator *)showInWindow:(UIWindow *)window {
    
    SPModalActivityIndicator *alertView = [[SPModalActivityIndicator alloc] initWithFrame:CGRectZero];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    [activityIndicator startAnimating];
    
    [alertView showWithContentView:activityIndicator window:window];
    
    return alertView;
}

- (void)showWithContentView:(UIView *)cView window:(UIWindow *)window {
    
    self.contentView = cView;
    topView = window;

    self.contentView.clipsToBounds = YES;
    
    [self applyStyling];
    [self setupLayout];
    
    self.alpha = 0.2;
    self.contentView.transform = CGAffineTransformMakeScale(4.0, 4.0);
    
    [UIView animateWithDuration:0.6
                          delay:0.0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         self.alpha = 1.0;
                         self.contentView.transform = CGAffineTransformIdentity;
                         
                     } completion:nil];
}

- (void)applyStyling {
    
    self.backgroundColor = [UIColor simplenoteModalOverlayColor];
}

-(void)setupLayout {
    
    CGRect topViewBounds = topView.bounds;
    
    float contentHeight = _contentView.frame.size.height;
    float contentWidth = _contentView.frame.size.width;
    
    float boxHeight = contentHeight;
    float boxWidth = contentWidth;
    
    float xOrigin = (topView.bounds.size.width - boxWidth) / 2;
    float yOrigin = (topView.bounds.size.height - boxWidth) / 2;
    
    boxFrame = CGRectMake(xOrigin, yOrigin, boxWidth, boxHeight);

    
    CGRect contentFrame = CGRectMake(boxFrame.origin.x, boxFrame.origin.y, contentWidth, contentHeight);
    self.contentView.frame = contentFrame;
    
    self.frame = topViewBounds;
    [self setNeedsDisplay];
    
    [self addSubview:self.contentView];
    [topView addSubview:self];
    
    self.userInteractionEnabled = YES;
}

- (void)dismiss:(BOOL)animated completion:(void (^)())completion {
    
    if (!animated)
        [self dismissComplete];
    else {
        
        [UIView animateWithDuration:0.1
                         animations:^{
            
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:1.0
                                  delay:0.0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.5
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
                                 self.alpha = 0.0;
                                 self.contentView.transform = CGAffineTransformMakeScale(0.5, 0.5);
                                 
                             } completion:^(BOOL finished) {
                                 [self dismissComplete];
                             }];
        }];
    }
    
}

- (void)dismissComplete {
    
    [self removeFromSuperview];
}

@end
