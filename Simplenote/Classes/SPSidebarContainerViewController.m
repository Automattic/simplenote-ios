#import "SPSidebarContainerViewController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"
#import <UIKit/UIKit.h>


static const CGFloat SPSidebarContainerSidePanelWidth           = 300;
static const CGFloat SPSidebarContainerInitialPanThreshold      = 0;
static const CGFloat SPSidebarContainerMinimumPanThreshold      = 30.0;
static const CGFloat SPSidebarContainerAnimationDelay           = 0;
static const CGFloat SPSidebarContainerAnimationDuration        = 0.4;
static const CGFloat SPSidebarContainerAnimationDurationZero    = 0.0;
static const CGFloat SPSidebarContainerAnimationDamping         = 1.5;
static const CGFloat SPSidebarContainerAnimationInitialVelocity = 6;


@interface SPSidebarContainerViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIViewController              *menuViewController;
@property (nonatomic, strong) UIViewController              *mainViewController;
@property (nonatomic, strong) UITapGestureRecognizer        *mainViewTapGestureRegoznier;
@property (nonatomic, strong) UIPanGestureRecognizer        *mainViewPanGestureRecognizer;
@property (nonatomic, assign) CGPoint                       rootViewStartingOrigin;
@property (nonatomic, assign) CGPoint                       sidePanelStartingOrigin;
@property (nonatomic, assign) BOOL                          isMenuViewVisible;
@property (nonatomic, assign) BOOL                          isMainViewPanning;
@property (nonatomic, assign) BOOL                          isPanningInitialized;

@end

@implementation SPSidebarContainerViewController

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                        menuViewController:(UIViewController *)menuViewController {

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
    }
    
    return self;
}


#pragma mark - Dynamic Properties

- (UIView *)mainView {
    return self.mainViewController.view;
}

- (UIView *)menuView {
    return self.menuViewController.view;
}

- (UIViewController *)visibleViewController {
    return self.isMenuViewVisible ? self.menuViewController : self.mainViewController;
}

- (UIView *)mainChildView {
    if ([self.mainViewController isKindOfClass:UINavigationController.class] == false) {
        return self.mainView;
    }

    UINavigationController *navigationController = (UINavigationController *)self.mainViewController;
    return navigationController.visibleViewController.view ?: self.mainView;
}


#pragma mark - Overridden Methods

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        // In iOS 13 we'll just... let the OS decide
        return UIStatusBarStyleDefault;
    }

    return SPUserInterface.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}


#pragma mark - Initialization

- (void)configureMainView {
    self.view.backgroundColor = [UIColor colorWithName:UIColorNameBackgroundColor];
}

- (void)configurePanGestureRecognizer {
    NSParameterAssert(self.mainView);

    self.mainViewPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidPan:)];
    self.mainViewPanGestureRecognizer.delegate = self;
}

- (void)configureTapGestureRecognizer {
    self.mainViewTapGestureRegoznier = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rootViewTapped:)];
    self.mainViewTapGestureRegoznier.numberOfTapsRequired = 1;
    self.mainViewTapGestureRegoznier.numberOfTouchesRequired = 1;
    self.mainViewTapGestureRegoznier.delegate = self;
}

- (void)configureViewControllerContainment {
    NSParameterAssert(self.mainViewController);
    NSParameterAssert(self.menuViewController);

    [self addChildViewController:self.mainViewController];
    [self addChildViewController:self.menuViewController];
}

- (void)attachMainView {
    NSParameterAssert(self.mainView);

    [self.view addSubview:self.mainView];
}


#pragma mark - UIGestureRecognizers

- (void)viewDidPan:(UIPanGestureRecognizer *)gesture {

    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {

        if (!self.isMainViewPanning) {
            return;
        }

        self.isMainViewPanning = NO;

        BOOL exceededPanThreshold = self.mainView.frame.origin.x >= _rootViewStartingOrigin.x + SPSidebarContainerMinimumPanThreshold;

        if (!self.isMenuViewVisible && exceededPanThreshold) {
            [self showSidePanel];
            return;
        }

        [self hideSidePanelAnimated:YES];
        return;

    } else if (gesture.state != UIGestureRecognizerStateBegan) {

        CGFloat translation = [gesture translationInView:self.mainView].x;

        if (!self.isMainViewPanning) {
            // See if moved more than 0 pixels in correct direction
            if ( (self.isMenuViewVisible ? translation : -translation) > SPSidebarContainerInitialPanThreshold ) {
                return;
            }
        }

        if (!self.isMainViewPanning && !self.isPanningInitialized) {
            if (![self.delegate sidebarContainerShouldDisplayMenu]) {
                return;
            }

            [SPTracker trackSidebarSidebarPanned];
            [self setupForPanning];
        }

        if (!self.isMainViewPanning) {
            _rootViewStartingOrigin = self.mainView.frame.origin;
            _sidePanelStartingOrigin = self.menuView.frame.origin;
        }

        self.isMainViewPanning = YES;
        CGRect newMainFrame = self.mainView.frame;
        newMainFrame.origin = _rootViewStartingOrigin;
        newMainFrame.origin.x += translation;
        newMainFrame.origin.x = MIN(MAX(newMainFrame.origin.x, 0), SPSidebarContainerSidePanelWidth);
        self.mainView.frame = newMainFrame;

        CGRect newMenuFrame = self.menuView.frame;
        newMenuFrame.origin = _sidePanelStartingOrigin;
        newMenuFrame.origin.x += translation;
        newMenuFrame.origin.x = MIN(MAX(newMenuFrame.origin.x, -SPSidebarContainerSidePanelWidth), 0);
        self.menuView.frame = newMenuFrame;
    }
}

- (void)rootViewTapped:(UITapGestureRecognizer *)gesture {
    [self hideSidePanelAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)setupForPanning {

    [self.delegate sidebarContainerWillDisplayMenu];

    CGRect sidePanelFrame = self.view.bounds;
    sidePanelFrame.origin.x -= SPSidebarContainerSidePanelWidth;
    sidePanelFrame.size.width = SPSidebarContainerSidePanelWidth;
    self.menuView.frame = sidePanelFrame;
    self.menuView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    self.menuViewController.additionalSafeAreaInsets = self.mainChildView.safeAreaInsets;

    [self.view insertSubview:self.menuView atIndex:0];

    self.isPanningInitialized = YES;
}


#pragma mark - Public API

- (void)toggleSidePanel {
    if (self.isMenuViewVisible) {
        [self hideSidePanelAnimated:YES];
    } else {
        [self showSidePanel];
    }
}

- (void)showSidePanel {
    if (!self.isPanningInitialized) {
        if (![self.delegate sidebarContainerShouldDisplayMenu]) {
            return;
        }

        [self setupForPanning];
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

                         [self.mainView addGestureRecognizer:self.mainViewTapGestureRegoznier];

                         self.isMenuViewVisible = YES;
                     }];
}

- (void)hideSidePanelAnimated:(BOOL)animated {

    [self.delegate sidebarContainerWillHideMenu];

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

                         [self.mainView removeGestureRecognizer:self.mainViewTapGestureRegoznier];
                         [self.menuView removeFromSuperview];

                         self.isMenuViewVisible = NO;
                         self.isPanningInitialized = NO;

                         [self.delegate sidebarContainerDidHideMenu];

                         [UIViewController attemptRotationToDeviceOrientation];
                     }];
}

@end

