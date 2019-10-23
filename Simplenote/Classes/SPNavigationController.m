#import "SPNavigationController.h"
#import "Simplenote-Swift.h"


static const NSInteger SPNavigationBarBackgroundPositionZ = -1000;


@interface SPNavigationController ()
@property (nonatomic, strong) UIVisualEffectView *navigationBarBackground;
@end

@implementation SPNavigationController


#pragma mark - Dynamic Properties

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshBlurEffect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startListeningToNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopListeningToNotifications];
}

- (void)setDisableBlurEffect:(BOOL)disableBlurEffect
{
    _disableBlurEffect = disableBlurEffect;
    [self refreshBlurEffect];
}

- (UIVisualEffectView *)navigationBarBackground
{
    if (_navigationBarBackground) {
        return _navigationBarBackground;
    };

    UIBlurEffect *effect = [UIBlurEffect simplenoteBlurEffect];

    UIVisualEffectView *navigationBarBackground = [[UIVisualEffectView alloc] initWithEffect:effect];
    navigationBarBackground.userInteractionEnabled = NO;
    navigationBarBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    navigationBarBackground.layer.zPosition = SPNavigationBarBackgroundPositionZ;

    _navigationBarBackground = navigationBarBackground;

    return _navigationBarBackground;
}


#pragma mark - Blur Effect Support

- (void)startListeningToNotifications
{
    // No need to do this in iOS +13
    if (@available(iOS 13, *)) {
        return;
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(refreshBlurStyle) name:VSThemeManagerThemeDidChangeNotification object:nil];
}

- (void)stopListeningToNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshBlurEffect
{
    if (self.disableBlurEffect) {
        [self detachNavigationBarBackground];
        return;
    }

    [self attachNavigationBarBackground:self.navigationBarBackground toNavigationBar:self.navigationBar];
}

- (void)refreshBlurStyle
{
    self.navigationBarBackground.effect = [UIBlurEffect simplenoteBlurEffect];
}

- (void)detachNavigationBarBackground
{
    [_navigationBarBackground removeFromSuperview];
}

- (void)attachNavigationBarBackground:(UIVisualEffectView *)barBackground toNavigationBar:(UINavigationBar *)navigationBar
{
    CGSize statusBarSize = UIApplication.sharedApplication.statusBarFrame.size;
    CGRect bounds = navigationBar.bounds;
    bounds.origin.y -= statusBarSize.height;
    bounds.size.height += statusBarSize.height;
    barBackground.frame = bounds;

    [navigationBar addSubview:barBackground];
    [navigationBar sendSubviewToBack:barBackground];
}


#pragma mark - Overridden Methods

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (@available(iOS 13.0, *)) {
        // In iOS 13 we'll just... let the OS decide
        return UIStatusBarStyleDefault;
    }

    return SPUserInterface.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate
{
    return !_disableRotation;
}

@end
