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

@end
