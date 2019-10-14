#import <UIKit/UIKit.h>


@protocol SPSidebarContainerDelegate <NSObject>
@required
- (BOOL)sidebarContainerShouldDisplayMenu;
- (void)sidebarContainerWillDisplayMenu;
- (void)sidebarContainerWillHideMenu;
- (void)sidebarContainerDidHideMenu;
@end


@interface SPSidebarContainerViewController : UIViewController

@property (nonatomic, strong, readonly) UIViewController                *menuViewController;
@property (nonatomic, strong, readonly) UIViewController                *mainViewController;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer          *mainViewPanGestureRecognizer;
@property (nonatomic, weak) id<SPSidebarContainerDelegate>              delegate;

- (instancetype)initWithMainViewController:(UIViewController *)mainViewController
                        menuViewController:(UIViewController *)menuViewController;

- (void)toggleSidePanel;
- (void)showSidePanel;
- (void)hideSidePanelAnimated:(BOOL)animated;

@end
