//
//  VSThemeManager.h
//  Simplenote
//
//  Created by Tom Witkin on 7/6/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSTheme.h"
#import "VSThemeLoader.h"

extern NSString *const VSThemeManagerThemeWillChangeNotification;
extern NSString *const VSThemeManagerThemeDidChangeNotification;
extern NSString *const VSThemeManagerThemePrefKey;

@interface VSThemeManager : NSObject

+ (VSThemeManager *)sharedManager;

- (VSTheme *)theme;
- (VSThemeLoader *)themeLoader;

- (void)swapTheme:(NSString *)theme;

- (void)applyAppearanceStylingForTheme:(VSTheme *)theme;

@end
