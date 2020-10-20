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

NS_ASSUME_NONNULL_BEGIN

extern NSString *const VSThemeManagerThemePrefKey;

@interface VSThemeManager : NSObject

+ (VSThemeManager *)sharedManager;

- (VSTheme *)theme;
- (VSThemeLoader *)themeLoader;

- (void)swapTheme:(NSString *)theme;

@end

NS_ASSUME_NONNULL_END
