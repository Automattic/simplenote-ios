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

NSString *const VSThemeManagerThemeWillChangeNotification;
NSString *const VSThemeManagerThemeDidChangeNotification;
NSString *const VSThemeManagerThemePrefKey;

@interface VSThemeManager : NSObject

+ (VSThemeManager *)sharedManager;

- (VSTheme *)theme;
- (VSThemeLoader *)themeLoader;

- (void)swapTheme:(NSString *)theme;

- (void)applyAppearanceStylingForTheme:(VSTheme *)theme;

@end