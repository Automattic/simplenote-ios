//
//  UIDevice+Extensions.h
//  Simplenote
//
//  Created by Jorge Leandro Perez on 3/18/15.
//  Copyright (c) 2015 Automattic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Extensions)

+ (BOOL)isPad;
+ (BOOL)isPhone;
+ (BOOL)isPhoneX;
+ (BOOL)isLandscape;
+ (BOOL)isPhoneLandscape;

@end
