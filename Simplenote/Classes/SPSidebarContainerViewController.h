#import <UIKit/UIKit.h>


@class SPSidebarContainerViewController;


@protocol SPSidebarContainerDelegate <NSObject>
@required
- (BOOL)sidebarContainerShouldDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerWillDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerDidDisplaySidebar:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerWillHideSidebar:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerDidHideSidebar:(SPSidebarContainerViewController *)sidebarContainer;
@end


@interface SPSidebarContainerViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController        *sidebarViewController;
@property (nonatomic, strong, readonly) UIViewController        *mainViewController;
@property (nonatomic, assign, readonly) BOOL                    isSidebarVisible;
@property (nonatomic, assign) BOOL                              automaticallyMatchSidebarInsetsWithMainInsets;
@property (nonatomic, weak) id<SPSidebarContainerDelegate>      delegate;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                     sidebarViewController:(UIViewController *)sidebarViewController;

- (void)toggleSidebar;
- (void)showSidebar;
- (void)hideSidebarWithAnimation:(BOOL)animated;
- (void)requirePanningToFail;

@end
