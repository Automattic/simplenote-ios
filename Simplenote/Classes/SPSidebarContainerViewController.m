#import "SPSidebarContainerViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import <UIKit/UIKit.h>

static const CGFloat SPDirectionalIdentity                  = 1;
static const CGFloat SPDirectionalInverted                  = -1;
static const CGFloat SPSidebarWidth                         = 300;
static const CGFloat SPSidebarAnimationThreshold            = 0.15;
static const CGFloat SPSidebarAnimationDuration             = 0.35;
static const CGFloat SPSidebarAnimationDamping              = 10;
static const CGVector SPSidebarAnimationInitialVelocity     = {-10, 0};
static const CGFloat SPSidebarAnimationCompletionMin        = 0.001;
static const CGFloat SPSidebarAnimationCompletionMax        = 0.999;
static const CGFloat SPSidebarAnimationCompletionFactorFull = 1.0;
static const CGFloat SPSidebarAnimationCompletionFactorZero = 0.0;

@interface SPSidebarContainerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController              *sidebarViewController;
@property (nonatomic, strong) UIViewController              *mainViewController;
@property (nonatomic, strong) UIViewPropertyAnimator        *animator;
@property (nonatomic, strong) UITapGestureRecognizer        *mainViewTapGestureRecognier;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
@property (nonatomic, assign) BOOL                          isSidebarVisible;
@property (nonatomic, assign) BOOL                          isPanningActive;

@end

@implementation SPSidebarContainerViewController

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                     sidebarViewController:(UIViewController *)sidebarViewController
{
    NSParameterAssert(mainViewController);
    NSParameterAssert(sidebarViewController);

    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
        self.sidebarViewController = sidebarViewController;
        self.automaticallyMatchSidebarInsetsWithMainInsets = YES;

        [self configurePanGestureRecognizer];
        [self configureTapGestureRecognizer];
        [self configureViewControllerContainment];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureView];
    [self attachMainView];
    [self attachSidebarView];
    [self startListeningToNotifications];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods
{
    // We're officially taking over the Appearance Methods sequence, for Child ViewControllers
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mainViewController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.mainViewController endAppearanceTransition];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mainViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mainViewController endAppearanceTransition];
}


#pragma mark - Dynamic Properties

- (UIView *)mainView
{
    return self.mainViewController.view;
}

- (UIView *)sidebarView
{
    return self.sidebarViewController.view;
}

- (UIView *)mainChildView
{
    // We assume that the MainViewController might actually be a UINavigationController, and we'll return the Top View
    return self.mainNavigationController.viewControllers.firstObject.view ?: self.mainView;
}

- (UITableView *)mainChildTableView
{
    return [self.mainChildView firstSubviewAsTableView];
}

- (UITableView *)sideChildTableView
{
    return [self.sidebarView firstSubviewAsTableView];
}

- (UIViewController *)activeViewController
{
    return self.isSidebarVisible ? self.sidebarViewController : self.mainViewController;
}

- (UINavigationController *)mainNavigationController
{
    if (![self.mainViewController isKindOfClass:UINavigationController.class]) {
        return nil;
    }

    return (UINavigationController *)self.mainViewController;
}


#pragma mark - Overridden Methods

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate
{
    return !self.isPanningActive && [self.activeViewController shouldAutorotate];
}


#pragma mark - Initialization

- (void)configureView
{
    NSParameterAssert(self.panGestureRecognizer);

    self.view.backgroundColor = [UIColor simplenoteBackgroundColor];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)configurePanGestureRecognizer
{
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureWasRecognized:)];
    self.panGestureRecognizer.delegate = self;
}

- (void)configureTapGestureRecognizer
{
    self.mainViewTapGestureRecognier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rootViewTapped:)];
    self.mainViewTapGestureRecognier.numberOfTapsRequired = 1;
    self.mainViewTapGestureRecognier.numberOfTouchesRequired = 1;
}

- (void)configureViewControllerContainment
{
    NSParameterAssert(self.mainViewController);
    NSParameterAssert(self.sidebarViewController);

    [self.mainViewController willMoveToParentViewController:self];
    [self.sidebarViewController willMoveToParentViewController:self];
    [self addChildViewController:self.mainViewController];
    [self addChildViewController:self.sidebarViewController];
    [self.mainViewController didMoveToParentViewController:self];
    [self.sidebarViewController didMoveToParentViewController:self];
}

- (void)attachMainView
{
    NSParameterAssert(self.mainView);

    [self.view addSubview:self.mainView];
}

- (void)attachSidebarView
{
    NSParameterAssert(self.sidebarView);

    CGRect sidePanelFrame = self.view.bounds;
    sidePanelFrame.origin.x = self.isRightToLeft ? sidePanelFrame.size.width : -SPSidebarWidth;
    sidePanelFrame.size.width = SPSidebarWidth;

    UIView *sidebarView = self.sidebarView;
    sidebarView.frame = sidePanelFrame;
    sidebarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

    [self.view insertSubview:sidebarView atIndex:0];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    [coder encodeObject:self.mainViewController forKey:@"MainControllerEncodeKey"];
    [coder encodeObject:self.sidebarViewController forKey:@"SideControllerEncodeKey"];
}

#pragma mark - Notifications

- (void)startListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshStyle)
                                                 name:SPSimplenoteThemeChangedNotification
                                               object:nil];
}

- (void)refreshStyle
{
    self.view.backgroundColor = [UIColor simplenoteBackgroundColor];
}


#pragma mark - Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
{
    if (recognizer != self.panGestureRecognizer) {
        return YES;
    }

    CGPoint translation = [self.panGestureRecognizer translationInView:self.panGestureRecognizer.view];

    // Scenario A: It's a Vertical Swipe
    if (ABS(translation.x) < ABS(translation.y)) {
        return NO;
    }

    // Scenario B: Sidebar is NOT visible, and we got a Left Swipe (OR) Sidebar is Visible and we got a Right Swipe
    CGFloat normalizedTranslation = translation.x * self.directionalMultiplier;
    if ((!self.isSidebarVisible && normalizedTranslation < 0) || (self.isSidebarVisible && normalizedTranslation > 0)) {
        return NO;
    }

    // Scenario C: Sidebar or Main are being dragged
    if (self.mainChildTableView.dragging || self.sideChildTableView.dragging) {
        return NO;
    }

    // Scenario D: Sidebar is not visible, but there are multiple viewControllers in its hierarchy
    if (!self.isSidebarVisible && self.mainNavigationController.viewControllers.count > 1) {
        return NO;
    }

    // Scenario E: Sidebar is not visible, but the delegate says NO, NO!
    if (!self.isSidebarVisible && ![self.delegate sidebarContainerShouldDisplaySidebar:self]) {
        return NO;
    }

    // Scenario F: Sidebar is visible and is being edited
    if (self.isSidebarVisible && self.sidebarViewController.isEditing) {
        return NO;
    }

    // Scenario G: We're still tracking something?
    if (self.isPanningActive) {
        return NO;
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // Why is this needed: UITableView's swipe gestures might require our Pan gesture to fail. Capisci?
    if (gestureRecognizer != self.panGestureRecognizer) {
        return YES;
    }

    // In the name of your king, stop this madness!
    return !self.isPanningActive;
}


#pragma mark - Helpers

// The following method will (attempt) to match the Sidebar's TableViewInsets with the MainView's SafeAreaInsets.
// Ideally, the first Sidebar row will be aligned against the SearchBar on its right hand side.
//
- (void)ensureSideTableViewInsetsMatchMainViewInsets
{
    UIEdgeInsets mainSafeInsets = self.mainChildView.safeAreaInsets;
    UITableView* sideTableView = self.sideChildTableView;

    if (!self.automaticallyMatchSidebarInsetsWithMainInsets || sideTableView == nil) {
        return;
    }

    UIEdgeInsets contentInsets = sideTableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = sideTableView.verticalScrollIndicatorInsets;

    contentInsets.top = mainSafeInsets.top;
    contentInsets.bottom = mainSafeInsets.bottom;

    // Yes. Not setting the bottomInsets on purpose.
    scrollIndicatorInsets.top = mainSafeInsets.top;

    if (UIEdgeInsetsEqualToEdgeInsets(sideTableView.contentInset, contentInsets)) {
        return;
    }

    sideTableView.contentInset = contentInsets;
    sideTableView.scrollIndicatorInsets = scrollIndicatorInsets;

    [sideTableView scrollToTopWithAnimation:NO];
}


#pragma mark - UIViewPropertyAnimator

- (UIViewPropertyAnimator *)animatorForSidebarVisibility:(BOOL)visible
{
    CGAffineTransform transform = visible ?
                                    CGAffineTransformMakeTranslation(SPSidebarWidth * self.directionalMultiplier, 0) :
                                    CGAffineTransformIdentity;

    CGFloat alphaSidebar = visible ? UIKitConstants.alpha1_0 : UIKitConstants.alpha0_0;
    CGFloat alphaMain = visible ? UIKitConstants.alpha0_5 : UIKitConstants.alpha1_0;
    UISpringTimingParameters *parameters = [[UISpringTimingParameters alloc] initWithDampingRatio:SPSidebarAnimationDamping
                                                                                  initialVelocity:SPSidebarAnimationInitialVelocity];

    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:SPSidebarAnimationDuration
                                                                       timingParameters:parameters];

    [animator addAnimations:^{
        self.mainView.transform = transform;
        self.mainView.alpha = alphaMain;
        self.sidebarView.transform = transform;
        self.sidebarView.alpha = alphaSidebar;
    }];

    return animator;
}


#pragma mark - UIGestureRecognizers

- (void)panGestureWasRecognized:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        BOOL newVisibility = !self.isSidebarVisible;
        self.animator = [self animatorForSidebarVisibility:newVisibility];
        self.isPanningActive = YES;

        [self beginSidebarTransition:newVisibility];
        [SPTracker trackSidebarSidebarPanned];

    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {

        if (self.animator.fractionComplete < SPSidebarAnimationThreshold) {
            self.animator.reversed = YES;
            [self beginSidebarTransition:self.isSidebarVisible];
        } else {
            self.isSidebarVisible = !self.isSidebarVisible;
        }

        __weak typeof(self) weakSelf = self;
        BOOL didBecomeVisible = self.isSidebarVisible;

        [self.animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
            __strong __typeof(weakSelf) strongSelf = weakSelf;

            strongSelf.isPanningActive = NO;
            [strongSelf endSidebarTransition:didBecomeVisible];
            [UIViewController attemptRotationToDeviceOrientation];
        }];

        [self.animator continueAnimationWithTimingParameters:nil durationFactor:SPSidebarAnimationCompletionFactorFull];

    } else {
        CGPoint translation = [gesture translationInView:self.mainView];
        CGFloat translationMultiplier = self.isSidebarVisible ? -1 : 1;
        CGFloat progress = translation.x / SPSidebarWidth * translationMultiplier * self.directionalMultiplier;

        self.animator.fractionComplete = MAX(SPSidebarAnimationCompletionMin, MIN(SPSidebarAnimationCompletionMax, progress));
    }
}

- (void)rootViewTapped:(UITapGestureRecognizer *)gesture
{
    if (self.isPanningActive) {
        return;
    }

    [self hideSidebarWithAnimation:YES];
}


#pragma mark - Panning

- (void)beginSidebarTransition:(BOOL)isAppearing
{
    if (isAppearing) {
        [self.delegate sidebarContainerWillDisplaySidebar:self];
        [self ensureSideTableViewInsetsMatchMainViewInsets];
    } else {
        [self.delegate sidebarContainerWillHideSidebar:self];
    }

    [self.sidebarViewController beginAppearanceTransition:isAppearing animated:YES];
}

- (void)endSidebarTransition:(BOOL)appeared
{
    if (appeared) {
        [self.delegate sidebarContainerDidDisplaySidebar:self];
        [self.mainView addGestureRecognizer:self.mainViewTapGestureRecognier];
    } else {
        [self.delegate sidebarContainerDidHideSidebar:self];
        [self.mainView removeGestureRecognizer:self.mainViewTapGestureRecognier];
    }

    [self.sidebarViewController endAppearanceTransition];
}


#pragma mark - RTL Support

- (BOOL)isRightToLeft
{
    return UIApplication.sharedApplication.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

/// The purpose of this method is to normalize calculations, regardless of the writing direction, so that we do not need to duplicate checks.
///
/// Rather than checking:
///     `isRTL == false && translation.x < 0` OR `isRTL == true ^^ translation.x > 0`,
///
/// We can simply check for:
///     `translation.x * directionalMultiplier < 0`.
///
- (CGFloat)directionalMultiplier
{
    return self.isRightToLeft ? SPDirectionalInverted : SPDirectionalIdentity;
}


#pragma mark - Public API

- (void)toggleSidebar
{
    if (self.isSidebarVisible) {
        [self hideSidebarWithAnimation:YES];
    } else {
        [self showSidebar];
    }
}

- (void)showSidebar
{
    if (self.isPanningActive || self.isSidebarVisible) {
        return;
    }

    [self beginSidebarTransition:YES];

    UIViewPropertyAnimator *animator = [self animatorForSidebarVisibility:YES];

    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self.isSidebarVisible = YES;
        [self endSidebarTransition:YES];
    }];

    [animator startAnimation];
    self.animator = animator;
}

- (void)hideSidebarWithAnimation:(BOOL)animated
{
    if (self.isPanningActive || !self.isSidebarVisible) {
        return;
    }

    [self beginSidebarTransition:NO];

    UIViewPropertyAnimator *animator = [self animatorForSidebarVisibility:NO];

    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        self.isSidebarVisible = NO;
        [self endSidebarTransition:NO];
        [UIViewController attemptRotationToDeviceOrientation];
    }];

    if (animated) {
        [animator startAnimation];
    } else {
        animator.fractionComplete = 1;
        [animator continueAnimationWithTimingParameters:nil durationFactor:SPSidebarAnimationCompletionFactorZero];
    }

    self.animator = animator;
}

- (void)requirePanningToFail
{
    [self.panGestureRecognizer fail];
}

@end
