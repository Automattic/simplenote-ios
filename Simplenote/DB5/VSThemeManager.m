//
//  VSThemeManager.m
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "VSThemeManager.h"
#import "SPAppDelegate.h"
#import "SPNavigationController.h"
#import "SPTracker.h"
#import "Simplenote-Swift.h"

NSString *const VSThemeManagerThemeWillChangeNotification = @"VSThemeManagerThemeWillChangeNotification";
NSString *const VSThemeManagerThemeDidChangeNotification = @"VSThemeManagerThemeDidChangeNotification";
NSString *const VSThemeManagerThemePrefKey = @"VSThemeManagerThemePrefKey";

@interface VSThemeManager ()

@property (nonatomic, strong) VSThemeLoader *themeLoader;
@property (nonatomic, strong) VSTheme *theme;

@end

@implementation VSThemeManager

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (VSThemeManager *)sharedManager
{
    static VSThemeManager *sharedManager = nil;
    if (!sharedManager) {
        sharedManager = [[VSThemeManager alloc] init];
        
        // load theme
        sharedManager.themeLoader = [VSThemeLoader new];
        
        NSString *themeName = [[NSUserDefaults standardUserDefaults] objectForKey:VSThemeManagerThemePrefKey];
        if (themeName) {
            sharedManager.theme = [sharedManager.themeLoader themeNamed:themeName];
        }
        
        if (!sharedManager.theme)
            sharedManager.theme = sharedManager.themeLoader.defaultTheme;
        
        // register for font size change notifications
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager
                                                 selector:@selector(contentSizeCategoryDidChange:)
                                                     name:UIContentSizeCategoryDidChangeNotification
                                                   object:nil];
        
    }
    
    return sharedManager;
}

- (VSTheme *)theme {
    
    return _theme;
}

- (VSThemeLoader *)themeLoader {
    
    return _themeLoader;
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification {
    
    for (VSTheme *theme in self.themeLoader.themes) {
        
        [theme clearCaches];
    }
    
    [self swapTheme:self.theme.name];
}

- (void)swapTheme:(NSString *)themeName {
    
    VSTheme *theme = [self.themeLoader themeNamed:themeName];
    
    if (theme) {
        
        BOOL newTheme = ![theme.name.lowercaseString isEqualToString:self.theme.name];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:VSThemeManagerThemeWillChangeNotification
                                                            object:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:themeName
                                                  forKey:VSThemeManagerThemePrefKey];
        
        _theme = theme;
        [self applyAppearanceStyling];
        [[NSNotificationCenter defaultCenter] postNotificationName:VSThemeManagerThemeDidChangeNotification
                                                            object:nil];
        
        if (newTheme) {
            [SPTracker trackSettingsThemeUpdated:themeName];	
        }
    }
}


- (void)applyAppearanceStyling {

    /// Style: BarButtonItem
    ///
    NSDictionary *barButtonTitleAttributes = @{
        NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
    };

    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonTitleAttributes forState:UIControlStateNormal];

    /// Style: NavigationBar
    ///
    UIColor *barTintColor = [UIColor colorWithName:UIColorNameBackgroundColor];
    UIImage *navbarShadowImage = [UIImage navigationBarShadowImage];
    UIImage *navbarBackgroundImage = [UIImage imageWithName:UIImageNameNavigationBarBackgroundImage];
    UIImage *navbarPromptImage = [UIImage imageWithName:UIImageNameNavigationBarBackgroundPromptImage];

    if (@available(iOS 13, *)) {
        // WHY we're disabling the `resizableImage:` for iOS +13:
        //
        //  1.  It neutralizes iOS 13's "effective asset" resolution capabilities. The UI ends up stuck with the incorrect image.
        //  2.  Tested in an array of devices. iOS *is* stretching the image automatically, anyways
        //  3.  The asset itself is a line of 1x44pt. No curved areas, it's okay to stretch without considering insets.
        //
        //  *Plus:* Yes, we'd much rather having @available == false. BUT that triggers an Xcode warning!
        //
    } else {
        navbarBackgroundImage = [navbarBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 0, 0)];
        navbarPromptImage = [navbarPromptImage resizableImageWithCapInsets:UIEdgeInsetsMake(64, 0, 0, 0)];
    }

    NSDictionary *barTitleAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: [UIColor colorWithName:UIColorNameNavigationBarTitleFontColor]
    };

    id barAppearance = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]];
    [barAppearance setBarTintColor:barTintColor];
    [barAppearance setBackgroundImage:navbarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [barAppearance setBackgroundImage:navbarPromptImage forBarMetrics:UIBarMetricsDefaultPrompt];
    [barAppearance setShadowImage:navbarShadowImage];
    [barAppearance setTitleTextAttributes:barTitleAttributes];
}

@end
