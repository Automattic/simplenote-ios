//
//  SPNavigationController.m
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPNavigationController.h"
#import "VSThemeManager.h"


@interface SPNavigationController ()

@end

@implementation SPNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    BOOL dark = [[[VSThemeManager sharedManager] theme] isDark];
    return dark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate {
    
    return !_disableRotation;
}

@end
