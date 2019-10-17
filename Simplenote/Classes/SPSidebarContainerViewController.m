#import "SPSidebarContainerViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import <UIKit/UIKit.h>


static const CGFloat SPSidebarContainerSidePanelWidth               = 300;
static const CGFloat SPSidebarContainerInitialPanThreshold          = 0;
static const CGFloat SPSidebarContainerTranslationRatioThreshold    = 0.3;
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
@property (nonatomic, assign) BOOL                          isPanningInitialized;

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

- (UIViewController *)visibleViewController
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

- (UIView *)mainChildView
{
    return self.mainNavigationController.visibleViewController.view ?: self.mainView;
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
    return [self.visibleViewController shouldAutorotate];
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

    // Scenario A: Menu is visible and in being edited
    if (self.isMenuViewVisible && self.menuViewController.isEditing) {
        return NO;
    }

    // Scenario B: Main is visible, but there are multiple viewControllers in its hierarchy
    if (!self.isMenuViewVisible && self.mainNavigationController.viewControllers.count > 1) {
        return NO;
    }

    // Scenario C: Main is visible, but the delegate says NO, NO!
    if (!self.isMenuViewVisible && ![self.delegate sidebarContainerShouldDisplayMenu:self]) {
        return NO;
    }

    CGPoint translation = [self.panGestureRecognizer translationInView:self.panGestureRecognizer.view];

    // Scenario D: It's a Vertical Swipe
    if (ABS(translation.x) < ABS(translation.y)) {
        return NO;
    }

    // Scenario E: Menu is visible, and we get a left swipe
    if (self.isMenuViewVisible && translation.x > 0) {
        return NO;
    }

    // Scenario F: Menu is NOT visible, and we get a right swipe
    if (!self.isMenuViewVisible && translation.x < 0) {
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

    // Whenever we're actually panning, stop this!
    return !self.isMainViewPanning;
}


#pragma mark - UIGestureRecognizers

- (void)viewDidPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {

        if (!self.isMainViewPanning) {
            return;
        }

        self.isMainViewPanning = NO;

        CGPoint translation = [gesture translationInView:self.mainView];
        CGPoint velocity = [gesture velocityInView:gesture.view];
        CGFloat minimumTranslationThreshold = self.mainView.frame.size.width * SPSidebarContainerTranslationRatioThreshold;

        BOOL exceededTranslationThreshold = ABS(translation.x) >= minimumTranslationThreshold;
        BOOL exceededVelocityThreshold = ABS(velocity.x) > SPSidebarContainerMinimumVelocityThreshold;
        BOOL exceededGestureThreshold = exceededTranslationThreshold || exceededVelocityThreshold;

        if ((!self.isMenuViewVisible && exceededGestureThreshold) || (self.isMenuViewVisible && !exceededGestureThreshold)) {
            [self showSidePanel];
            return;
        }

        [self hideSidePanelAnimated:YES];
        return;

    } else if (gesture.state != UIGestureRecognizerStateBegan) {

        CGFloat translation = [gesture translationInView:self.mainView].x;

        if (!self.isMainViewPanning) {
            if ((self.isMenuViewVisible ? translation : -translation) > SPSidebarContainerInitialPanThreshold) {
                return;
            }

            if (![self ensureMainViewPanningIsInitialized]) {
                return;
            }

            self.mainViewStartingOrigin = self.mainView.frame.origin;
            self.menuPanelStartingOrigin = self.menuView.frame.origin;
            self.isMainViewPanning = YES;
        }

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

- (BOOL)ensureMainViewPanningIsInitialized
{
    if (self.isPanningInitialized) {
        return YES;
    }

    if (![self.delegate sidebarContainerShouldDisplayMenu:self]) {
        return NO;
    }

    [self initializeMainViewPanning];
    return YES;
}

- (void)initializeMainViewPanning
{
    [SPTracker trackSidebarSidebarPanned];

    [self.delegate sidebarContainerWillDisplayMenu:self];

    self.menuViewController.additionalSafeAreaInsets = self.mainChildView.safeAreaInsets;
    [self.menuViewController beginAppearanceTransition:YES animated:YES];

    self.isPanningInitialized = YES;
}


#pragma mark - Public API

- (void)toggleSidePanel
{
    [SPTracker trackSidebarSidebarPanned];

    if (self.isMenuViewVisible) {
        [self hideSidePanelAnimated:YES];
    } else {
        [self showSidePanel];
    }
}

- (void)showSidePanel
{
    if (![self ensureMainViewPanningIsInitialized]) {
        return;
    }

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

                         [self.mainView addGestureRecognizer:self.mainViewTapGestureRecognier];

                         [self.delegate sidebarContainerDidSDisplayMenu:self];
                         [self.menuViewController endAppearanceTransition];

                         self.isMenuViewVisible = YES;
                     }];
}

- (void)hideSidePanelAnimated:(BOOL)animated
{
    [self.delegate sidebarContainerWillHideMenu:self];
    [self.menuViewController beginAppearanceTransition:NO animated:YES];

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

                         [self.mainView removeGestureRecognizer:self.mainViewTapGestureRecognier];

                         [self.delegate sidebarContainerDidHideMenu:self];
                         [self.menuViewController endAppearanceTransition];

                         self.isMenuViewVisible = NO;
                         self.isPanningInitialized = NO;

                         [UIViewController attemptRotationToDeviceOrientation];
                     }];
}

- (void)requireToFailPanning
{
    [self.panGestureRecognizer fail];
}

@end

