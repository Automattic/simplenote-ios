//
//  SPSidebarContainerViewController.h
//  Simplenote
//
//  Created by Tom Witkin on 10/14/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SPSidebarContainerViewController, SPSidebarViewController;

@protocol SPContainerSidePanelViewDelegate <NSObject>

@required

- (BOOL)containerViewControllerShouldShowSidePanel:(SPSidebarContainerViewController *)container;

@optional
- (void)containerViewControllerWillSlide:(SPSidebarContainerViewController *)container;
- (void)containerViewControllerDidSlide:(SPSidebarContainerViewController *)container;
- (void)containerViewControllerWillShowSidePanel:(SPSidebarContainerViewController *)container;
- (void)containerViewControllerDidShowSidePanel:(SPSidebarContainerViewController *)container;
- (void)containerViewControllerDidHideSidePanel:(SPSidebarContainerViewController *)container;
- (void)containerViewController:(SPSidebarContainerViewController *)container didChangeContentInset:(UIEdgeInsets)contentInset;
@end


@interface SPSidebarContainerViewController : UIViewController <UIGestureRecognizerDelegate> {
    
    id<SPContainerSidePanelViewDelegate> sidePanelViewDelegate;
    
    UITapGestureRecognizer *rootViewTapGesture;
    
    BOOL bRootViewIsPanning;
    BOOL bSetupForPanning;
    BOOL bShowingTemporaryBarButtonItem;
}

@property (nonatomic, assign) id<SPContainerSidePanelViewDelegate> sidePanelViewDelegate;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIView *rootView;
@property (nonatomic, strong) SPSidebarViewController *sidePanelViewController;

@property (nonatomic) BOOL bSidePanelVisible;

- (instancetype)initWithSidebarViewController:(SPSidebarViewController *)sidebarViewController;

- (void)toggleSidePanel:(void (^)())completion;;
- (void)showSidePanel:(void (^)())completion;
- (void)showFullSidePanelWithTemporaryBarButton:(UIBarButtonItem *)item
                                     completion:(void (^)())completion;
- (void)hideSidePanelAnimated:(BOOL)animated completion:(void (^)())completion;

// Methods that should be implemented by subclasses
- (BOOL)shouldShowSidebar;
- (void)sidebarWillShow;
- (void)sidebarDidShow;
- (void)sidebarDidHide;
- (void)sidebarDidSlideToPercentVisible:(CGFloat)percentVisible;
- (void)resetNavigationBar;

@end
