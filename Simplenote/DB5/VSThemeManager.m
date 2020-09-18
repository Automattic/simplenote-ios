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
        [[NSUserDefaults standardUserDefaults] setObject:themeName
                                                  forKey:VSThemeManagerThemePrefKey];
        
        _theme = theme;
    }
}

@end
