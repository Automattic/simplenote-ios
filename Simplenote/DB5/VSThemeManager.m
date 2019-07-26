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
        [self applyAppearanceStylingForTheme:_theme];
        [[NSNotificationCenter defaultCenter] postNotificationName:VSThemeManagerThemeDidChangeNotification
                                                            object:nil];
        
        if (newTheme) {
            [SPTracker trackSettingsThemeUpdated:themeName];	
        }
    }
}


- (void)applyAppearanceStylingForTheme:(VSTheme *)theme {
    
    UIFont *barButtonFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:barButtonFont}
                                                forState:UIControlStateNormal];
    
    UIFont *navigationBarTitleFont = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    UIColor *navigationBarTitleColor = [UIColor colorWithName:UIColorNameNavigationBarTitleFontColor];
    UIColor *barTintColor = [UIColor colorWithName:UIColorNameBackgroundColor];

    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]] setTitleTextAttributes:@{NSFontAttributeName: navigationBarTitleFont,
                                                           NSForegroundColorAttributeName: navigationBarTitleColor}];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]] setBarTintColor:barTintColor];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]] setShadowImage:[[theme imageForKey:@"navigationBarShadowImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, 0, 0) resizingMode:UIImageResizingModeTile]];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]] setBackgroundImage:[[theme imageForKey:@"navigationBarBackgroundImage"]
                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(44, 0, 0, 0)]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[SPNavigationController class]]] setBackgroundImage:[[theme imageForKey:@"navigationBarBackgroundPromptImage"]
                                                      resizableImageWithCapInsets:UIEdgeInsetsMake(64, 0, 0, 0)]
                                       forBarMetrics:UIBarMetricsDefaultPrompt];
}

@end
