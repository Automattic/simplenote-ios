
//
//  SPInteractivePushPopAnimationController.m
//  Simplenote
//
//  Created by James Frost on 08/10/2015.
//  Copyright © 2015 Automattic. All rights reserved.
//

#import "SPInteractivePushPopAnimationController.h"
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
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] == false) {
        return YES;
    }

    UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    UIViewController *topViewController = self.navigationController.topViewController;
    CGPoint location = [panGestureRecognizer locationInView:navigationBar];
    CGPoint translation = [panGestureRecognizer translationInView:navigationBar];
    BOOL isLeftTranslation = translation.x < 0;
    BOOL isRightTranslation = translation.x > 0;
    BOOL isLTR = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute: topViewController.view.semanticContentAttribute] == UIUserInterfaceLayoutDirectionLeftToRight;

    BOOL isSwipeTranslation = isLTR ? isLeftTranslation : isRightTranslation;

    // Ignore touches within the navigation bar
    if (CGRectContainsPoint(navigationBar.bounds, location)) {
        return NO;
    }

    // TopViewController conforms to SPInteractivePushViewControllerProvider AND We're Swiping Right to Left: Support Push!
    if ([topViewController conformsToProtocol:@protocol(SPInteractivePushViewControllerProvider)] && isSwipeTranslation) {
        UIViewController <SPInteractivePushViewControllerProvider> *pushProviderController = (UIViewController <SPInteractivePushViewControllerProvider> *)topViewController;
        CGPoint locationInView = [panGestureRecognizer locationInView:pushProviderController.view];
        if (![pushProviderController interactivePushPopAnimationControllerShouldBeginPush:self touchPoint:locationInView]) {
            return NO;
        }

        // `StandardInteractivePopGestureWidth` is an estimate of how wide the standard navigation
        // controller interactive pop gesture recognizer's detection area is.
        return (location.x >= SPStandardInteractivePopGestureWidth);
    }

    // Pop Gesture: Let's leave `UINavigationController.interactivePopGestureRecognizer` deal with it.
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
    toView.alpha = UIKitConstants.alpha0_0;
    
    void (^transition)() = ^void() {
        fromView.frame = fromViewFinalFrame;
        toView.frame = toViewFinalFrame;
        fromView.alpha = UIKitConstants.alpha0_0;
        toView.alpha = UIKitConstants.alpha1_0;
    };
    
    void (^completion)(BOOL) = ^void(BOOL finished) {
        BOOL completed = ![transitionContext transitionWasCancelled];
        if (!completed) {
            fromView.frame = fromViewInitialFrame;
            [toView removeFromSuperview];
        }

        // We must restore fromView's alpha value. Otherwise `UINavigationController.interactivePopGestureRecognizer`
        // will end up displaying a blank UI.
        fromView.alpha = UIKitConstants.alpha1_0;

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
