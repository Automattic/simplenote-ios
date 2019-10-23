
//
//  SPInteractivePushPopAnimationController.m
//  Simplenote
//
//  Created by James Frost on 08/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPInteractivePushPopAnimationController.h"
#import "UIDevice+Extensions.h"
#import "Simplenote-Swift.h"

CGFloat const SPStandardInteractivePopGestureWidth = 20.0f;
CGFloat const SPGestureTargetSwipeVelocity = 100.0f;
CGFloat const SPGestureTargetPercentageComplete = 0.5f;
CGFloat const SPPushAnimationDurationRegular = 0.5f;
CGFloat const SPPushAnimationDurationCompact = 0.3f;

@interface SPInteractivePushPopAnimationController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@end


@implementation SPInteractivePushPopAnimationController

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    self = [super init];
    if (self) {
        _navigationController = navigationController;
        
        [_navigationController.view addGestureRecognizer:[self interactivePanGestureRecognizer]];
    }
    
    return self;
}

#pragma mark - Gesture Recognizer 

/// Gesture recognizer used to initiate an interactive push / pop
- (UIPanGestureRecognizer *)interactivePanGestureRecognizer
{
    UIPanGestureRecognizer *gestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(handlePanGesture:)];
    gestureRecogniser.delegate = self;
    gestureRecogniser.cancelsTouchesInView = NO;
    
    return gestureRecogniser;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.navigationController.navigationBar];
    
    // Ignore touches within the navigation bar
    if (CGRectContainsPoint(self.navigationController.navigationBar.bounds, location)) {
        return NO;
    }

    // If the top view controller conforms to the protocol, we're doing an interactive push
    // which means that we need to leave the system interactive pop gesture's touch area alone
    if ([self.navigationController.topViewController conformsToProtocol:@protocol(SPInteractivePushViewControllerProvider)]) {
        UIViewController <SPInteractivePushViewControllerProvider> *topViewController = (UIViewController <SPInteractivePushViewControllerProvider> *)self.navigationController.topViewController;
        if ([topViewController respondsToSelector:@selector(interactivePushPopAnimationControllerShouldBeginPush:)]) {
            if (![topViewController interactivePushPopAnimationControllerShouldBeginPush:self]) {
                return NO;
            }
        }
        // `kStandardInteractivePopGestureWidth` is an estimate of how wide the standard navigation
        // controller interactive pop gesture recognizer's detection area is.
        if (location.x < SPStandardInteractivePopGestureWidth) {
            return NO;
        }

        return YES;
    }

    // If the top view controller is content that we've pushed, then then return YES
    // so that we can detect a swipe back to the provider.
    if ([self.navigationController.topViewController conformsToProtocol:@protocol(SPInteractivePushViewControllerContent)]) {
        return YES;
    }
    
    return NO;
}

- (void)handlePanGesture:(UIScreenEdgePanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self beginTransition];
            break;
        case UIGestureRecognizerStateChanged:
            [self updateTransitionWithGestureTranslation:[gesture translationInView:self.navigationController.view]];
            break;
        case UIGestureRecognizerStateEnded:
            [self endTransitionWithGestureVelocity:[gesture velocityInView:self.navigationController.view]];
            break;
        default:
            [self cancelTransition];
            break;
    }
}

- (void)beginTransition
{
    self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
    
    // If the top view controller conforms to the protocol, we're doing a push
    if ([self.navigationController.topViewController conformsToProtocol:@protocol(SPInteractivePushViewControllerProvider)]) {
        self.navigationOperation = UINavigationControllerOperationPush;
        
        id<SPInteractivePushViewControllerProvider> topVC = (id<SPInteractivePushViewControllerProvider>)self.navigationController.topViewController;

        [topVC interactivePushPopAnimationControllerWillBeginPush:self];
        
        UIViewController *nextViewController = [topVC nextViewControllerForInteractivePush];
        [self.navigationController pushViewController:nextViewController animated:YES];
    } else {
        self.navigationOperation = UINavigationControllerOperationPop;
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/// Updates the % completion of the `interactiveTransition` based on the translation of the user's touch within the view.
- (void)updateTransitionWithGestureTranslation:(CGPoint)translation
{
    CGFloat viewWidth = CGRectGetWidth(self.navigationController.view.bounds);
    CGFloat xTranslation = translation.x;
    
    if (self.navigationOperation == UINavigationControllerOperationPush) {
        xTranslation = MIN(xTranslation, 0);
    } else if (self.navigationOperation == UINavigationControllerOperationPop) {
        xTranslation = MAX(xTranslation, 0);
    }
    
    CGFloat percentage = fabs(xTranslation) / viewWidth;
    [self.interactiveTransition updateInteractiveTransition:MIN(MAX(percentage, 0), 1)];
}

- (void)endTransitionWithGestureVelocity:(CGPoint)velocity
{
    BOOL velocityExceedsTarget = NO;
    
    if (self.navigationOperation == UINavigationControllerOperationPush) {
        velocityExceedsTarget = velocity.x < -SPGestureTargetSwipeVelocity;
    } else if (self.navigationOperation == UINavigationControllerOperationPop) {
        velocityExceedsTarget = velocity.x > SPGestureTargetSwipeVelocity;
    }
    
    if (self.interactiveTransition.percentComplete > SPGestureTargetPercentageComplete || velocityExceedsTarget) {
        [self.interactiveTransition finishInteractiveTransition];
    } else {
        [self.interactiveTransition cancelInteractiveTransition];
    }

    [self cleanupTransition];
}

- (void)cancelTransition
{
    [self.interactiveTransition cancelInteractiveTransition];
    
    [self cleanupTransition];
}

- (void)cleanupTransition
{
    _interactiveTransition = nil;
    
    self.navigationOperation = UINavigationControllerOperationNone;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // A fast animation looks a little odd when the editor is very wide,
    // so use a slightly longer duration for regular width
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    if ([fromView isHorizontallyCompact]) {
        return SPPushAnimationDurationCompact;
    }
    
    return SPPushAnimationDurationRegular;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    CGRect fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];

    CGRect fromViewFinalFrame = toViewFinalFrame;
    CGRect toViewInitialFrame = fromViewInitialFrame;
    
    if (self.navigationOperation == UINavigationControllerOperationPush) {
        fromViewFinalFrame.origin.x -= fromViewInitialFrame.size.width;
        toViewInitialFrame.origin.x += fromViewInitialFrame.size.width;
    } else if (self.navigationOperation == UINavigationControllerOperationPop) {
        fromViewFinalFrame.origin.x += fromViewInitialFrame.size.width;
        toViewInitialFrame.origin.x -= fromViewInitialFrame.size.width;
    }
    
    [containerView insertSubview:toView aboveSubview:fromView];
    
    fromView.frame = fromViewInitialFrame;
    toView.frame = toViewInitialFrame;
    toView.alpha = 0;
    
    void (^transition)() = ^void() {
        fromView.frame = fromViewFinalFrame;
        toView.frame = toViewFinalFrame;
        fromView.alpha = 0.0f;
        toView.alpha = 1.0f;
    };
    
    void (^completion)(BOOL) = ^void(BOOL finished) {
        BOOL completed = ![transitionContext transitionWasCancelled];
        
        if (!completed) {
            fromView.frame = fromViewInitialFrame;
            fromView.alpha = 1.0f;
            [toView removeFromSuperview];
        }
        
        [transitionContext completeTransition:completed];
    };
    
    UIViewAnimationOptions curve = ([transitionContext isInteractive]) ?
        UIViewAnimationOptionCurveLinear : UIViewAnimationOptionCurveEaseInOut;
    
    if ([transitionContext isAnimated]) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0
                            options:curve
                         animations:transition
                         completion:completion];
    } else {
        transition();
        completion(true);
    }
}

@end
