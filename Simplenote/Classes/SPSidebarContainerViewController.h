#import <UIKit/UIKit.h>


@class SPSidebarContainerViewController;


@protocol SPSidebarContainerDelegate <NSObject>
@required
- (BOOL)sidebarContainerShouldDisplayMenu:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerWillDisplayMenu:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerDidDisplayMenu:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerWillHideMenu:(SPSidebarContainerViewController *)sidebarContainer;
- (void)sidebarContainerDidHideMenu:(SPSidebarContainerViewController *)sidebarContainer;
@end


@interface SPSidebarContainerViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController        *menuViewController;
@property (nonatomic, strong, readonly) UIViewController        *mainViewController;
@property (nonatomic, assign) BOOL                              automaticallyMatchMenuInsetsWithMainInsets;
@property (nonatomic, weak) id<SPSidebarContainerDelegate>      delegate;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                        menuViewController:(UIViewController *)menuViewController;

- (void)toggleSidePanel;
- (void)showSidePanel;
- (void)hideSidePanelAnimated:(BOOL)animated;
- (void)requireToFailPanning;

@end
