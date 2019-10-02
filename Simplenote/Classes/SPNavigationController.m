//
//  SPNavigationController.m
//  Simplenote
//
//  Created by Tom Witkin on 10/13/13.
//  Copyright (c) 2013 Automattic. All rights reserved.
//

#import "SPNavigationController.h"
#import "Simplenote-Swift.h"


@interface SPNavigationController ()

@end

@implementation SPNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) {
        // In iOS 13 we'll just... let the OS decide
        return UIStatusBarStyleDefault;
    }

    return SPUserInterface.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (BOOL)shouldAutorotate {
    
    return !_disableRotation;
}

@end
