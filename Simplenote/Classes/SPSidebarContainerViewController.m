#import "SPSidebarContainerViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import <UIKit/UIKit.h>


static const CGFloat SPSidebarContainerSidePanelWidth               = 300;
static const CGFloat SPSidebarContainerTranslationRatioThreshold    = 0.15;
static const CGFloat SPSidebarContainerMinimumVelocityThreshold     = 300.0;
static const CGFloat SPSidebarContainerAnimationDelay               = 0;
static const CGFloat SPSidebarContainerAnimationDuration            = 0.4;
static const CGFloat SPSidebarContainerAnimationDurationZero        = 0.0;
static const CGFloat SPSidebarContainerAnimationDamping             = 1.5;
static const CGFloat SPSidebarContainerAnimationInitialVelocity     = 6;


@interface SPSidebarContainerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController              *menuViewController;
@property (nonatomic, strong) UIViewController              *mainViewController;
@property (nonatomic, strong) UITapGestureRecognizer        *mainViewTapGestureRecognier;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
@property (nonatomic, assign) CGPoint                       mainViewStartingOrigin;
@property (nonatomic, assign) CGPoint                       menuPanelStartingOrigin;
@property (nonatomic, assign) BOOL                          isMenuViewVisible;
@property (nonatomic, assign) BOOL                          isMainViewPanning;

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
    // We're officially taking over the Appearance Methods sequence. Otherwise the MenuViewController will get
    // Appearance calls when it's actually... not it's time!
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
    // We assume that the MainViewController might actually be a UINavigationController, and attempt to
    // grab the first ViewController's View.
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
    if (self.isMainViewPanning) {
        return NO;
    }

    return [self.activeViewController shouldAutorotate];
}


#pragma mark - Initialization

- (void)configureMainView
{
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
}

- (void)configurePanGestureRecognizer
{
    NSParameterAssert(self.mainView);

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
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
    sidePanelFrame.origin.x -= SPSidebarContainerSidePanelWidth;
    sidePanelFrame.size.width = SPSidebarContainerSidePanelWidth;

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

    // Scenario B: Menu is NOT visible, and we get a right swipe
    if (!self.isMenuViewVisible && translation.x < 0) {
        return NO;
    }

    // Scenario C: Menu is visible, and we get a left swipe
    if (self.isMenuViewVisible && translation.x > 0) {
        return NO;
    }

    // Scenario D: Menu or Main are being dragged
    if (self.mainChildTableView.dragging || self.menuChildTableView.dragging) {
        return NO;
    }

    // Scenario E: Main is visible, but there are multiple viewControllers in its hierarchy
    if (!self.isMenuViewVisible && self.mainNavigationController.viewControllers.count > 1) {
        return NO;
    }

    // Scenario F: Menu is visible and is being edited
    if (self.isMenuViewVisible && self.menuViewController.isEditing) {
        return NO;
    }

    // Scenario G: Main is visible, but the delegate says NO, NO!
    if (!self.isMenuViewVisible && ![self.delegate sidebarContainerShouldDisplayMenu:self]) {
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

    // Whenever we're actually panning: In the name of your king, stop this madness!
    return !self.isMainViewPanning;
}


#pragma mark - Helpers

- (BOOL)mustHideSidePanelWithTranslation:(CGPoint)translation velocity:(CGPoint)velocity
{
    // We'll consider the `intent` in this OP, regardless of the distance covered (AKA Velocity Direction).
    CGFloat minimumTranslationThreshold = self.mainView.frame.size.width * SPSidebarContainerTranslationRatioThreshold;

    BOOL exceededTranslationThreshold   = ABS(translation.x) >= minimumTranslationThreshold;
    BOOL exceededVelocityThreshold      = ABS(velocity.x) > SPSidebarContainerMinimumVelocityThreshold;
    BOOL exceededGestureThreshold       = exceededTranslationThreshold || exceededVelocityThreshold;
    BOOL directionTowardsRight          = velocity.x > 0;
    BOOL directionTowardsLeft           = !directionTowardsRight;

    return ((self.isMenuViewVisible && exceededGestureThreshold && directionTowardsLeft) ||
            (!self.isMenuViewVisible && !(exceededGestureThreshold && directionTowardsRight)));
}


#pragma mark - UIGestureRecognizers

- (void)viewDidPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled ||
        gesture.state == UIGestureRecognizerStateFailed)
    {
        if (!self.isMainViewPanning) {
            return;
        }

        // End the "Appropriate" Transition: If the menu was visible, we've signaled we would be hiding it
        self.isMainViewPanning = NO;
        [self endAppropriateTransition];

        // And now: Based on both, Translation and Velocity, we'll figure out if we actually need to Show or Hide the Menu
        CGPoint translation = [gesture translationInView:self.mainView];
        CGPoint velocity = [gesture velocityInView:gesture.view];

        if ([self mustHideSidePanelWithTranslation:translation velocity:velocity]) {
            [self hideSidePanelAnimated:YES];
        } else {
            [self showSidePanel];
        }

    } else if (gesture.state == UIGestureRecognizerStateBegan) {

        // When a Pan OP begins, we don't really know if it'll end up showing the Menu, or hiding it.
        // Let's signal the "Appropriate" next transition. That is: if the menu is hidden, we'd expect to show it.
        // And, of course, whenever it's visible, we would expect to hide it!
        [self beginAppropriateTransition];
        self.mainViewStartingOrigin = self.mainView.frame.origin;
        self.menuPanelStartingOrigin = self.menuView.frame.origin;
        self.isMainViewPanning = YES;
        [SPTracker trackSidebarSidebarPanned];

    } else {
        CGFloat translation = [gesture translationInView:self.mainView].x;

        CGRect newMainFrame = self.mainView.frame;
        newMainFrame.origin = self.mainViewStartingOrigin;
        newMainFrame.origin.x += translation;
        newMainFrame.origin.x = MIN(MAX(newMainFrame.origin.x, 0), SPSidebarContainerSidePanelWidth);
        self.mainView.frame = newMainFrame;

        CGRect newMenuFrame = self.menuView.frame;
        newMenuFrame.origin = self.menuPanelStartingOrigin;
        newMenuFrame.origin.x += translation;
        newMenuFrame.origin.x = MIN(MAX(newMenuFrame.origin.x, -SPSidebarContainerSidePanelWidth), 0);
        self.menuView.frame = newMenuFrame;
    }
}

- (void)rootViewTapped:(UITapGestureRecognizer *)gesture
{
    [self hideSidePanelAnimated:YES];
}


#pragma mark - Panning

- (void)beginAppropriateTransition
{
    if (self.isMenuViewVisible) {
        [self beginHideMenuTransition];
    } else {
        [self beginDisplayMenuTransition];
    }
}

- (void)endAppropriateTransition
{
    if (self.isMenuViewVisible) {
        [self endHideMenuTransition];
    } else {
        [self endDisplayMenuTransition];
    }
}

- (void)beginDisplayMenuTransition
{
    [self.delegate sidebarContainerWillDisplayMenu:self];
    self.menuViewController.additionalSafeAreaInsets = self.mainChildView.safeAreaInsets;
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

    CGRect newMainViewFrame = self.mainView.frame;
    newMainViewFrame.origin.x = SPSidebarContainerSidePanelWidth;

    CGRect newMenuViewFrame = self.menuView.frame;
    newMenuViewFrame.origin.x = 0;
    newMenuViewFrame.size.width = SPSidebarContainerSidePanelWidth;

    [UIView animateWithDuration:SPSidebarContainerAnimationDuration
                          delay:SPSidebarContainerAnimationDelay
         usingSpringWithDamping:SPSidebarContainerAnimationDamping
          initialSpringVelocity:SPSidebarContainerAnimationInitialVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         self.mainView.frame = newMainViewFrame;
                         self.menuView.frame = newMenuViewFrame;

                     } completion:^(BOOL finished) {

                         [self endDisplayMenuTransition];
                        self.isMenuViewVisible = YES;
                     }];
}

- (void)hideSidePanelAnimated:(BOOL)animated
{
    [self beginHideMenuTransition];

    CGRect newMainViewFrame = self.mainView.frame;
    newMainViewFrame.origin.x = 0;

    CGRect newMenuViewFrame = self.menuView.frame;
    newMenuViewFrame.origin.x = -newMenuViewFrame.size.width;

    [UIView animateWithDuration:animated ? SPSidebarContainerAnimationDuration : SPSidebarContainerAnimationDurationZero
                          delay:SPSidebarContainerAnimationDelay
         usingSpringWithDamping:SPSidebarContainerAnimationDamping
          initialSpringVelocity:SPSidebarContainerAnimationInitialVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

                         self.mainView.frame = newMainViewFrame;
                         self.menuView.frame = newMenuViewFrame;

                     } completion:^(BOOL finished) {

                         [self endHideMenuTransition];
                         self.isMenuViewVisible = NO;
                         [UIViewController attemptRotationToDeviceOrientation];
                     }];
}

- (void)requireToFailPanning
{
    [self.panGestureRecognizer fail];
}

@end

