//
//  UIDevice+Extensions.m
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/18/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import "UIDevice+Extensions.h"

@implementation UIDevice (Extensions)

+ (BOOL)isPad
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isPhone
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isPhoneX
{
    CGFloat maxScreenWidth = MAX([[UIScreen mainScreen] bounds].size.width,
                              [[UIScreen mainScreen] bounds].size.height);
    return self.isPhone && maxScreenWidth == 812.0;
}

+ (BOOL)isLandscape
{
    return UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
}

+ (BOOL)isPhoneLandscape
{
    return self.isPhone && self.isLandscape;
}

@end
