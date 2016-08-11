//
//  SPSidebarContainerViewController.m
//  Simplenote
//
//  Created by Tom Witkin on 10/14/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPSidebarContainerViewController.h"
#import "SPNavigationController.h"
#import "SPSidebarViewController.h"
#import "VSThemeManager.h"
#import "SPTracker.h"

static CGFloat sidePanelWidth;

@interface SPSidebarContainerViewController ()

@property (nonatomic) CGPoint rootViewStartingOrigin;
@property (nonatomic) CGPoint sidePanelStartingOrigin;

@end

@implementation SPSidebarContainerViewController

- (id)initWithSidebarViewController:(SPSidebarViewController *)sidebarViewController {
    
    self = [super init];
    if (self) {
        
        self.view.backgroundColor = [self.theme colorForKey:@"backgroundColor"];
        
        // add root view to screen
        self.rootView = [[UIView alloc] initWithFrame:self.view.bounds];
        self.rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_rootView];
        
        // setup gesture recognizers
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(viewDidPan:)];
        panGesture.delegate = self;
        [self.rootView addGestureRecognizer:panGesture];
        
        _sidePanelViewController = sidebarViewController;
        _sidePanelViewController.containerViewController = self;
    }
    
    return self;
}

- (VSTheme *)theme {
    
    return [[VSThemeManager sharedManager] theme];
}



#pragma mark Delegates

- (id<SPContainerSidePanelViewDelegate>)sidePanelViewDelegate {
    
    return sidePanelViewDelegate;
}

- (void)setSidePanelViewDelegate:(id<SPContainerSidePanelViewDelegate>)newSidePanelViewDelegate {
    
    sidePanelViewDelegate = newSidePanelViewDelegate;
}


#pragma mark UIGestureRecognizers

- (void)viewDidPan:(UIPanGestureRecognizer *)gesture {
    
    // avoid swiping if collection view is already scrolling
    if (!bRootViewIsPanning && (![self shouldShowSidebar] ||
                                ![sidePanelViewDelegate containerViewControllerShouldShowSidePanel:self]))
        return;
    
    
        if (gesture.state == UIGestureRecognizerStateEnded ||
            gesture.state == UIGestureRecognizerStateCancelled) {
        
        if (!bRootViewIsPanning)
            return;
        
        bRootViewIsPanning = NO;
        
        UIView *view = gesture.view;
        
        // determine whether to show or hide the view
        if (!_bSidePanelVisible && view.frame.origin.x < _rootViewStartingOrigin.x + 30) {
            [self hideSidePanelAnimated:YES completion:nil];
            return;
        } else if (!_bSidePanelVisible) {
            [self showSidePanel:nil];
            return;
        }
        
        if (_bSidePanelVisible && view.frame.origin.x > _rootViewStartingOrigin.x - 30) {
            [self hideSidePanelAnimated:YES completion:nil];
            return;
        } else {
            [self hideSidePanelAnimated:YES completion:nil];
            return;
        }
        
    } else if (gesture.state != UIGestureRecognizerStateBegan) {
        
        CGFloat translation = [gesture translationInView:gesture.view].x;
        
        if (!bRootViewIsPanning) {
            
            // see if moved more than 10 pixels in correct direction
            CGFloat threshold = [self.theme floatForKey:@"containerViewPanThreshold"];
            
            if ( (_bSidePanelVisible ? translation : -translation) > threshold )
                return;
        }

        
        if (!bRootViewIsPanning && !bSetupForPanning) {
            
            [SPTracker trackSidebarSidebarPanned];
            [self setupForPanning];
        }
        
        if (!bRootViewIsPanning) {
            _rootViewStartingOrigin = _rootView.frame.origin;
            _sidePanelStartingOrigin = _sidePanelViewController.view.frame.origin;
        }
        
        
        bRootViewIsPanning = YES;
        CGRect newRootFrame = _rootView.frame;
        newRootFrame.origin = _rootViewStartingOrigin;
        newRootFrame.origin.x += translation;
        newRootFrame.origin.x = MAX(newRootFrame.origin.x, 0);
        newRootFrame.origin.x = MIN(newRootFrame.origin.x, sidePanelWidth);
        _rootView.frame = newRootFrame;
        
        CGRect newSidePanelFrame = _sidePanelViewController.view.frame;
        newSidePanelFrame.origin = _sidePanelStartingOrigin;
        newSidePanelFrame.origin.x += translation;
        newSidePanelFrame.origin.x = MAX(newSidePanelFrame.origin.x, -sidePanelWidth);
        newSidePanelFrame.origin.x = MIN(newSidePanelFrame.origin.x, 0);
        _sidePanelViewController.view.frame = newSidePanelFrame;
        
        if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerDidSlide:)])
            [sidePanelViewDelegate containerViewControllerDidSlide:self];
        
        // calculate percent visible
        CGFloat percentVisible = newRootFrame.origin.x / sidePanelWidth;
        percentVisible = MAX(0.0, percentVisible);
        percentVisible = MIN(1.0, percentVisible);
        [self sidebarDidSlideToPercentVisible:percentVisible];
    }
}

- (void)setupForPanning {
    
    [self sidebarWillShow];
    
    if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerWillSlide:)])
        [sidePanelViewDelegate containerViewControllerWillSlide:self];
    
    if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerWillShowSidePanel:)])
        [sidePanelViewDelegate containerViewControllerWillShowSidePanel:self];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sidePanelWidth = [self.theme floatForKey:@"containerViewSidePanelWidth"];
    });
    
    CGRect sidePanelFrame = self.view.bounds;
    sidePanelFrame.origin.x -= sidePanelWidth;
    sidePanelFrame.size.width = sidePanelWidth;
    _sidePanelViewController.view.frame = sidePanelFrame;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view insertSubview:_sidePanelViewController.view atIndex:0];
    });
    
    _sidePanelViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    [self applySidePanelContentInsets];
    
    bSetupForPanning = YES;
}

- (void)applySidePanelContentInsets {
    
    // set contentInsets based on rootViewController
    UIEdgeInsets contentInset = UIEdgeInsetsMake([[self topLayoutGuide] length],
                                                 0,
                                                 [[self bottomLayoutGuide] length],
                                                 0);
    [sidePanelViewDelegate containerViewController:self
                             didChangeContentInset:contentInset];
}

- (void)toggleSidePanel:(void (^)())completion {
    
    if (_bSidePanelVisible)
        [self hideSidePanelAnimated:YES completion:completion];
    else
        [self showSidePanel:completion];
    
}

- (void)showSidePanel:(void (^)())completion {
    
    if (!bSetupForPanning) {
        
        [SPTracker trackSidebarButtonPresed];
        
        if (![self shouldShowSidebar] || ![sidePanelViewDelegate containerViewControllerShouldShowSidePanel:self]) {
            return;
        }
        
        [self setupForPanning];
    }
    
    [self resetNavigationBar];
    
    CGRect newRootFrame = _rootView.frame;
    newRootFrame.origin.x = sidePanelWidth;
    
    CGRect newSidePanelFrame = _sidePanelViewController.view.frame;
    newSidePanelFrame.origin.x = 0;
    newSidePanelFrame.size.width = sidePanelWidth;

    CGFloat duration = [self.theme floatForKey:@"containerViewSpringAnimationDuration"];
    CGFloat damping = [self.theme floatForKey:@"containerViewSpringAnimationDamping"];
    CGFloat initialVelocity = [self.theme floatForKey:@"containerViewSpringAnimationInitialVelocity"];
    
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:damping
          initialSpringVelocity:initialVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         _rootView.frame = newRootFrame;
                         _sidePanelViewController.view.frame = newSidePanelFrame;
                         
                        [self sidebarDidSlideToPercentVisible:1.0];
                         
                     } completion:^(BOOL finished) {
                         
                         [_rootView removeGestureRecognizer:rootViewTapGesture];
                         
                         rootViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(rootViewTapped:)];
                         rootViewTapGesture.numberOfTapsRequired = 1;
                         rootViewTapGesture.numberOfTouchesRequired = 1;
                         rootViewTapGesture.delegate = self;
                         [_rootView addGestureRecognizer:rootViewTapGesture];
                         
                         _bSidePanelVisible = YES;
                         [self sidebarDidShow];
                         
                         if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerDidShowSidePanel:)])
                             [sidePanelViewDelegate containerViewControllerDidShowSidePanel:self];
                         
                         if (completion)
                             completion();
                     }];
}

- (void)showFullSidePanelWithTemporaryBarButton:(UIBarButtonItem *)item
                                     completion:(void (^)())completion {
    
    if (!bSetupForPanning) {
        
        if (![self shouldShowSidebar] ||
            ![sidePanelViewDelegate containerViewControllerShouldShowSidePanel:self])
            return;
        
        [self setupForPanning];
    }
    
    CGFloat sidePanelWidth = self.view.bounds.size.width;
    
    CGRect newRootFrame = _rootView.frame;
    newRootFrame.origin.x = sidePanelWidth;
    
    CGRect newSidePanelFrame = _sidePanelViewController.view.frame;
    newSidePanelFrame.origin.x = 0;
    newSidePanelFrame.size.width = sidePanelWidth;
    
    CGFloat duration = 2 * [self.theme floatForKey:@"containerViewSpringAnimationDuration"];
    CGFloat damping = [self.theme floatForKey:@"containerViewSpringAnimationDamping"];
    CGFloat initialVelocity = [self.theme floatForKey:@"containerViewSpringAnimationInitialVelocity"];
    
    
    if (item) {
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = item;
        self.navigationItem.titleView.hidden = YES;
        bShowingTemporaryBarButtonItem = YES;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
         usingSpringWithDamping:damping
          initialSpringVelocity:initialVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         _rootView.frame = newRootFrame;
                         _sidePanelViewController.view.frame = newSidePanelFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         _bSidePanelVisible = YES;
                         
                         [self sidebarDidShow];
                         
                         if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerDidShowSidePanel:)])
                             [sidePanelViewDelegate containerViewControllerDidShowSidePanel:self];
                         
                         if (completion)
                             completion();
                     }];
}


- (void)hideSidePanelAnimated:(BOOL)animated completion:(void (^)())completion {
    
    [self resetNavigationBar];
    
    CGRect newRootFrame = _rootView.frame;
    newRootFrame.origin.x = 0;
    
    CGRect newSidePanelFrame = _sidePanelViewController.view.frame;
    newSidePanelFrame.origin.x = -newSidePanelFrame.size.width;
    
    CGFloat duration = [self.theme floatForKey:@"containerViewSpringAnimationDuration"];
    CGFloat damping = [self.theme floatForKey:@"containerViewSpringAnimationDamping"];
    CGFloat initialVelocity = [self.theme floatForKey:@"containerViewSpringAnimationInitialVelocity"];
    
    
    [UIView animateWithDuration:animated ? duration : 0.0
                          delay:0.0
         usingSpringWithDamping:damping
          initialSpringVelocity:initialVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         
                         _rootView.frame = newRootFrame;
                         _sidePanelViewController.view.frame = newSidePanelFrame;
                         
                         [self sidebarDidSlideToPercentVisible:0.0];
                         
                     } completion:^(BOOL finished) {
                         
                         [_rootView removeGestureRecognizer:rootViewTapGesture];
                         rootViewTapGesture = nil;
                         
                         _bSidePanelVisible = NO;
                         
                         // remove side panel from view
                         [_sidePanelViewController.view removeFromSuperview];
                         
                         bSetupForPanning = NO;
                         
                         [self sidebarDidHide];
                         
                         if ([sidePanelViewDelegate respondsToSelector:@selector(containerViewControllerDidHideSidePanel:)])
                             [sidePanelViewDelegate containerViewControllerDidHideSidePanel:self];
                         
                         [UIViewController attemptRotationToDeviceOrientation];
                         
                         if (completion)
                             completion();
                     }];
}

- (void)rootViewTapped:(UITapGestureRecognizer *)gesture {
    
    [self hideSidePanelAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark Methods to be overridden by subclasses

// Methods that should be implemented by subclasses
- (BOOL)shouldShowSidebar {
    
    return YES;
}

- (void)sidebarWillShow {
    
}

- (void)sidebarDidShow {
    
}

- (void)sidebarDidHide {
    
}

- (void)sidebarDidSlideToPercentVisible:(CGFloat)percentVisible {
    
}

- (void)resetNavigationBar {
    
}


@end
