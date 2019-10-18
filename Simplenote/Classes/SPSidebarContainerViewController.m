#import "SPSidebarContainerViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import <UIKit/UIKit.h>


static const CGFloat SPSidebarMenuWidth                     = 300;
static const CGFloat SPSidebarAnimationThreshold            = 0.15;
static const CGFloat SPSidebarAnimationDuration             = 0.4;
static const CGFloat SPSidebarAnimationDamping              = 1.5;
static const CGVector SPSidebarAnimationInitialVelocity     = {6, 0};
static const CGFloat SPSidebarAnimationCompletionMin        = 0.001;
static const CGFloat SPSidebarAnimationCompletionMax        = 0.999;
static const CGFloat SPSidebarAnimationCompletionFactorFull = 1.0;
static const CGFloat SPSidebarAnimationCompletionFactorZero = 0.0;

@interface SPSidebarContainerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController              *menuViewController;
@property (nonatomic, strong) UIViewController              *mainViewController;
@property (nonatomic, strong) UIViewPropertyAnimator        *animator;
@property (nonatomic, strong) UITapGestureRecognizer        *mainViewTapGestureRecognier;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
@property (nonatomic, assign) BOOL                          isMenuViewVisible;

@end

@implementation SPSidebarContainerViewController

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                        menuViewController:(UIViewController *)menuViewController
{
    NSParameterAssert(mainViewController);
    NSParameterAssert(menuViewController);

    self = [super init];
    if (self) {
        self.mainViewController = mainViewController;
        self.menuViewController = menuViewController;
        self.automaticallyMatchMenuInsetsWithMainInsets = YES;

        [self configureMainView];
        [self configurePanGestureRecognizer];
        [self configureTapGestureRecognizer];
        [self configureViewControllerContainment];
        [self attachMainView];
        [self attachMenuView];
    }
    
    return self;
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

- (UIView *)menuView
{
    return self.menuViewController.view;
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

- (UITableView *)menuChildTableView
{
    return [self.menuView firstSubviewAsTableView];
}

- (UIViewController *)activeViewController
{
    return self.isMenuViewVisible ? self.menuViewController : self.mainViewController;
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
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDefault;
    }

    return SPUserInterface.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate
{
    return !self.animator.isRunning && [self.activeViewController shouldAutorotate];
}


#pragma mark - Initialization

- (void)configureMainView
{
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
}

- (void)configurePanGestureRecognizer
{
    NSParameterAssert(self.mainView);

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureWasRecognized:)];
    self.panGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.panGestureRecognizer];
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
    NSParameterAssert(self.menuViewController);

    [self addChildViewController:self.mainViewController];
    [self addChildViewController:self.menuViewController];
}

- (void)attachMainView
{
    NSParameterAssert(self.mainView);

    [self.view addSubview:self.mainView];
}

- (void)attachMenuView
{
    NSParameterAssert(self.menuView);

    CGRect sidePanelFrame = self.view.bounds;
    sidePanelFrame.origin.x -= SPSidebarMenuWidth;
    sidePanelFrame.size.width = SPSidebarMenuWidth;

    UIView *menuView = self.menuView;
    menuView.frame = sidePanelFrame;
    menuView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

    [self.view insertSubview:menuView atIndex:0];
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

    // Scenario B: Menu is NOT visible, and we got a Left Swipe (OR) Menu is Visible and we got a Right Swipe
    if ((!self.isMenuViewVisible && translation.x < 0) || (self.isMenuViewVisible && translation.x > 0)) {
        return NO;
    }

    // Scenario C: Menu or Main are being dragged
    if (self.mainChildTableView.dragging || self.menuChildTableView.dragging) {
        return NO;
    }

    // Scenario D: Main is visible, but there are multiple viewControllers in its hierarchy
    if (!self.isMenuViewVisible && self.mainNavigationController.viewControllers.count > 1) {
        return NO;
    }

    // Scenario E: Main is visible, but the delegate says NO, NO!
    if (!self.isMenuViewVisible && ![self.delegate sidebarContainerShouldDisplayMenu:self]) {
        return NO;
    }

    // Scenario F: Menu is visible and is being edited
    if (self.isMenuViewVisible && self.menuViewController.isEditing) {
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
    return !self.animator.isRunning;
}


#pragma mark - Helpers

// The following method will (attempt) to match the Menu's TableViewInsets with the MainView's SafeAreaInsets.
// Ideally, the first Menu row will be aligned against the SearchBar on its right hand side.
//
- (void)ensureMenuTableViewInsetsMatchMainViewInsets
{
    UIEdgeInsets mainSafeInsets = self.mainChildView.safeAreaInsets;
    UITableView* menuTableView = self.menuChildTableView;

    if (!self.automaticallyMatchMenuInsetsWithMainInsets || menuTableView == nil) {
        return;
    }

    UIEdgeInsets contentInsets = menuTableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = menuTableView.scrollIndicatorInsets;

    contentInsets.top = mainSafeInsets.top;
    contentInsets.bottom = mainSafeInsets.bottom;

    // Yes. Not setting the bottomInsets on purpose.
    scrollIndicatorInsets.top = mainSafeInsets.top;

    if (UIEdgeInsetsEqualToEdgeInsets(menuTableView.contentInset, contentInsets)) {
        return;
    }

    menuTableView.contentInset = contentInsets;
    menuTableView.scrollIndicatorInsets = scrollIndicatorInsets;

    [menuTableView scrollToTopWithAnimation:NO];
}


#pragma mark - UIViewPropertyAnimator

- (UIViewPropertyAnimator *)animatorForMenuVisibility:(BOOL)visible
{
    CGRect mainFrame = self.mainView.frame;
    CGRect menuFrame = self.menuView.frame;

    if (self.isMenuViewVisible) {
        mainFrame.origin.x = 0;
        menuFrame.origin.x = -menuFrame.size.width;
    } else {
        mainFrame.origin.x = SPSidebarMenuWidth;
        menuFrame.origin.x = 0;
    }

    UISpringTimingParameters *parameters = [[UISpringTimingParameters alloc] initWithDampingRatio:SPSidebarAnimationDamping
                                                                                  initialVelocity:SPSidebarAnimationInitialVelocity];

    UIViewPropertyAnimator *animator = [[UIViewPropertyAnimator alloc] initWithDuration:SPSidebarAnimationDuration
                                                                       timingParameters:parameters];

    [animator addAnimations:^{
        self.mainView.frame = mainFrame;
        self.menuView.frame = menuFrame;
    }];

    return animator;
}


#pragma mark - UIGestureRecognizers

- (void)panGestureWasRecognized:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {

        self.animator = [self animatorForMenuVisibility:!self.isMenuViewVisible];
        [SPTracker trackSidebarSidebarPanned];

    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {

        if (self.animator.fractionComplete > SPSidebarAnimationThreshold) {
            self.isMenuViewVisible = !self.isMenuViewVisible;
        } else {
            self.animator.reversed = YES;
        }

        [self.animator continueAnimationWithTimingParameters:nil durationFactor:SPSidebarAnimationCompletionFactorFull];

    } else {
        CGPoint translation = [gesture translationInView:self.mainView];
        CGFloat progress = ABS(translation.x / SPSidebarMenuWidth);
        self.animator.fractionComplete = MAX(SPSidebarAnimationCompletionMin, MIN(SPSidebarAnimationCompletionMax, progress));
    }
}

- (void)rootViewTapped:(UITapGestureRecognizer *)gesture
{
    [self hideSidePanelAnimated:YES];
}


#pragma mark - Panning

- (void)beginDisplayMenuTransition
{
    [self.delegate sidebarContainerWillDisplayMenu:self];
    [self ensureMenuTableViewInsetsMatchMainViewInsets];
    [self.menuViewController beginAppearanceTransition:YES animated:YES];
}

- (void)endDisplayMenuTransition
{
    [self.delegate sidebarContainerDidDisplayMenu:self];
    [self.menuViewController endAppearanceTransition];
    [self.mainView addGestureRecognizer:self.mainViewTapGestureRecognier];
}

- (void)beginHideMenuTransition
{
    [self.delegate sidebarContainerWillHideMenu:self];
    [self.menuViewController beginAppearanceTransition:NO animated:YES];
}

- (void)endHideMenuTransition
{
    [self.delegate sidebarContainerDidHideMenu:self];
    [self.menuViewController endAppearanceTransition];
    [self.mainView removeGestureRecognizer:self.mainViewTapGestureRecognier];
}


#pragma mark - Public API

- (void)toggleSidePanel
{
    if (self.isMenuViewVisible) {
        [self hideSidePanelAnimated:YES];
    } else {
        [self showSidePanel];
    }
}

- (void)showSidePanel
{
    [self beginDisplayMenuTransition];

    UIViewPropertyAnimator *animator = [self animatorForMenuVisibility:YES];

    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [self endDisplayMenuTransition];
        self.isMenuViewVisible = YES;
    }];

    [animator startAnimation];
    self.animator = animator;
}

- (void)hideSidePanelAnimated:(BOOL)animated
{
    [self beginHideMenuTransition];

    UIViewPropertyAnimator *animator = [self animatorForMenuVisibility:NO];

    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        [self endHideMenuTransition];
        self.isMenuViewVisible = NO;
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

- (void)requireToFailPanning
{
    [self.panGestureRecognizer fail];
}

@end
